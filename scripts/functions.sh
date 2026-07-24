#!/bin/bash
set -e

TMP_DIR=tmp
SEALED_SECRETS_FOLDER=components/operators/sealed-secrets-operator/overlays/default/
SEALED_SECRETS_SECRET=bootstrap/base/sealed-secrets-secret.yaml
TIMEOUT_SECONDS=60

# BSD sed (macOS, FreeBSD) requires an extension argument to -i (use '' for none).
# GNU sed accepts -i with no argument. This wrapper behaves on both.
sed_edit_inplace() {
  local script=$1
  local target=$2
  case "$(uname -s)" in
    Darwin|FreeBSD) sed -i '' "${script}" "${target}" ;;
    *) sed -i "${script}" "${target}" ;;
  esac
}

setup_bin(){
  mkdir -p ${TMP_DIR}/bin
  echo "${PATH}" | grep -q "${TMP_DIR}/bin" || \
    PATH=$(pwd)/${TMP_DIR}/bin:${PATH}
    export PATH
}

check_bin(){
  name=$1
  echo "Validating CLI tool: ${name}"
  
  which "${name}" || download_${name}
 
  case ${name} in
    oc|openshift-install|kustomize)
      echo "auto-complete: . <(${name} completion bash)"
      
      # shellcheck source=/dev/null
      . <(${name} completion bash)
      
      ${name} version
      ;;
    *)
      echo
      ${name} --version
      ;;
  esac
  echo
}

# Kubeseal releases can be found at:
# https://github.com/bitnami-labs/sealed-secrets/releases/
download_kubeseal(){
  KUBESEAL_VERSION="0.19.4"

  if [[ "$OSTYPE" == "darwin"* ]]; then
    # Mac OSX  
    if [[ $(uname -p) == 'arm' ]]; then
      DOWNLOAD_URL=https://github.com/bitnami-labs/sealed-secrets/releases/download/v${KUBESEAL_VERSION}/kubeseal-${KUBESEAL_VERSION}-darwin-arm64.tar.gz
    else
      DOWNLOAD_URL=https://github.com/bitnami-labs/sealed-secrets/releases/download/v${KUBESEAL_VERSION}/kubeseal-${KUBESEAL_VERSION}-darwin-amd64.tar.gz
    fi
  else
    # Linix
    if [[ $(uname -p) == 'arm' ]]; then
      DOWNLOAD_URL=https://github.com/bitnami-labs/sealed-secrets/releases/download/v${KUBESEAL_VERSION}/kubeseal-${KUBESEAL_VERSION}-linux-arm.tar.gz
    else
      DOWNLOAD_URL=https://github.com/bitnami-labs/sealed-secrets/releases/download/v${KUBESEAL_VERSION}/kubeseal-${KUBESEAL_VERSION}-linux-amd64.tar.gz
    fi  
  fi
  echo "Downloading Kubeseal: ${DOWNLOAD_URL}"

  curl "${DOWNLOAD_URL}" -L | tar vzx -C ${TMP_DIR}/bin kubeseal
}


download_ocp-install(){
  DOWNLOAD_URL=https://mirror.openshift.com/pub/openshift-v4/clients/ocp/stable-${OCP_VERSION}/openshift-install-linux.tar.gz
  curl "${DOWNLOAD_URL}" -L | tar vzx -C ${TMP_DIR}/bin openshift-install
}

download_oc(){
  if [[ ! "$OCP_VERSION" ]]; then
    echo "OCP version missing. Please provide OCP version when running this command!"
    exit 1
  fi
  if [[ "$OSTYPE" == "darwin"* ]]; then
    # Mac OSX  
    if [[ $(uname -p) == 'arm' ]]; then
      DOWNLOAD_URL=https://mirror.openshift.com/pub/openshift-v4/clients/ocp/stable-${OCP_VERSION}/openshift-client-mac-arm64.tar.gz
    else
      DOWNLOAD_URL=https://mirror.openshift.com/pub/openshift-v4/clients/ocp/stable-${OCP_VERSION}/openshift-client-mac.tar.gz
    fi
  else
    # Linux
    DOWNLOAD_URL=https://mirror.openshift.com/pub/openshift-v4/clients/ocp/stable-${OCP_VERSION}/openshift-client-linux.tar.gz
  fi
  echo "Downloading OpenShift CLI: ${DOWNLOAD_URL}" 
  
  curl "${DOWNLOAD_URL}" -L | tar vzx -C ${TMP_DIR}/bin oc
}

download_kustomize(){
  cd ${TMP_DIR}/bin
  curl -s "https://raw.githubusercontent.com/kubernetes-sigs/kustomize/master/hack/install_kustomize.sh" | bash
  cd ../..
}


# check login
check_oc_login(){
  oc cluster-info | head -n1
  oc whoami || exit 1
  echo
}

create_sealed_secret(){
  read -r -p "Create NEW [${SEALED_SECRETS_SECRET}]? [y/N] " input
  case $input in
    [yY][eE][sS]|[yY])

      oc apply -k ${SEALED_SECRETS_FOLDER}
      [ -e ${SEALED_SECRETS_SECRET} ] && return

      # TODO: explore using openssl
      # oc -n sealed-secrets -o yaml \
      #   create secret generic

      # just wait for it
      sleep 20

      oc -n sealed-secrets -o yaml \
        get secret \
        -l sealedsecrets.bitnami.com/sealed-secrets-key=active \
        > ${SEALED_SECRETS_SECRET}

      ;;
    [nN][oO]|[nN])
      echo
      ;;
    *)
      echo
      ;;
  esac
}

# Validate sealed secrets secret exists
check_sealed_secret(){
  if [ -f ${SEALED_SECRETS_SECRET} ]; then
    echo "Using Existing Sealed Secret: ${SEALED_SECRETS_SECRET}"
  else
    echo "Missing: ${SEALED_SECRETS_SECRET}"
    echo "The master key is required to bootstrap sealed secrets and CANNOT be checked into git."
    echo
    create_sealed_secret
  fi
}

wait_for_openshift_gitops(){
  echo "Checking status of all openshift-gitops pods"
  GITOPS_RESOURCES=(
    deployment/cluster:condition=Available \
    statefulset/openshift-gitops-application-controller:jsonpath='{.status.readyReplicas}'=1 \
    deployment/openshift-gitops-applicationset-controller:condition=Available \
    deployment/openshift-gitops-redis:condition=Available \
    deployment/openshift-gitops-repo-server:condition=Available \
    deployment/openshift-gitops-server:condition=Available \
  )

  for n in "${GITOPS_RESOURCES[@]}"
  do
    RESOURCE=$(echo $n | cut -d ":" -f 1)
    CONDITION=$(echo $n | cut -d ":" -f 2)

    echo "Waiting for ${RESOURCE} state to be ${CONDITION}..."

    if [[ "$RESOURCE" == "statefulset/openshift-gitops-application-controller" ]]; then

      # Here's a workaround for waiting for a stateful set to be deloyed:
      # https://github.com/kubernetes/kubernetes/issues/79606#issuecomment-1001246785
      # instead of: oc rollout status ${RESOURCE} -n ${ARGO_NS}

      oc wait pods --selector app.kubernetes.io/name=openshift-gitops-application-controller \
                   --for=condition=Ready -n ${ARGO_NS} --timeout=${TIMEOUT_SECONDS}s

    else   

      oc wait --for=${CONDITION} ${RESOURCE} -n ${ARGO_NS} --timeout=${TIMEOUT_SECONDS}s

    fi

  done
}

check_branch(){
  # New: Read from cluster overlay's configMapGenerator instead of base Application
  CLUSTER_KUSTOMIZATION="./clusters/overlays/${bootstrap_dir}/kustomization.yaml"

  if ! command -v yq &> /dev/null; then
    print_warning "yq could not be found.  We are unable to verify the branch of your repo."
    exit 1
  fi

  GIT_BRANCH=$(git rev-parse --abbrev-ref HEAD)

  # Extract targetRevision from configMapGenerator literal
  OVERLAY_BRANCH=$(yq -r '.configMapGenerator[] | select(.name == "gitops-repo-config") | .literals[]' ${CLUSTER_KUSTOMIZATION} | grep "^targetRevision=" | cut -d= -f2)

  if [[ ${GIT_BRANCH} == ${OVERLAY_BRANCH} ]] ; then
    echo
    echo "Your working branch ${GIT_BRANCH}, matches your cluster overlay branch ${OVERLAY_BRANCH}"
  else
    echo
    echo "Your current working branch is ${GIT_BRANCH}, and your cluster overlay branch is ${OVERLAY_BRANCH}."

    if [[ ${FORCE} == "true" ]] ; then
      echo "Updating to ${GIT_BRANCH}"
      update_configmap_branch ${CLUSTER_KUSTOMIZATION} ${GIT_BRANCH}
    else
      echo "Do you wish to update it to ${GIT_BRANCH}?"

      PS3="Please enter a number to select: "

      select yn in "Yes" "No"; do
          case $yn in
              Yes ) update_configmap_branch ${CLUSTER_KUSTOMIZATION} ${GIT_BRANCH}; break;;
              No ) break;;
          esac
      done
    fi
  fi

}

update_branch(){
 if [ -z "$1" ]; then
    echo "No patch file supplied."
    exit 1
  else
    APP_PATCH_FILE=$1
  fi

 if [ -z "$2" ]; then
    echo "No patch path supplied."
    exit 1
  else
    APP_PATCH_PATH=$2
  fi

  GIT_BRANCH=$(git rev-parse --abbrev-ref HEAD)

  yq "${APP_PATCH_PATH} = \"${GIT_BRANCH}\"" -i ${APP_PATCH_FILE}

  git add ${APP_PATCH_FILE}
  git commit -m "automatic update to branch by bootstrap script"
  git push origin ${GIT_BRANCH}
}

get_git_basename(){
  if [ -z "$1" ]; then
    echo "No repo provided."
    exit 1
  else
    REPO_URL=$1
  fi

  # Normalize the URL before parsing so we handle all the ways people
  # clone a repo: with/without a trailing slash, and with/without a
  # trailing ".git" suffix (e.g. "org/repo/", "org/repo/.git", "org/repo.git", "org/repo").
  NORMALIZED_URL=${REPO_URL%/}
  NORMALIZED_URL=${NORMALIZED_URL%.git}
  NORMALIZED_URL=${NORMALIZED_URL%/}

  QUERY='s#^(git@|https://)github\.com[:/]([a-zA-Z0-9_.-]+/[a-zA-Z0-9_.-]+)$#\2#'
  REPO_BASENAME=$(echo "${NORMALIZED_URL}" | sed -E "${QUERY}")

  # If the pattern didn't match (e.g. an unexpected/malformed URL), sed
  # returns the input unchanged. Detect that instead of silently passing
  # a bogus value back to callers who will build a new URL out of it.
  if [[ "${REPO_BASENAME}" == "${NORMALIZED_URL}" ]] || [[ ! "${REPO_BASENAME}" =~ ^[a-zA-Z0-9_.-]+/[a-zA-Z0-9_.-]+$ ]]; then
    echo "Unable to parse '${REPO_URL}' as a github.com org/repo URL." >&2
    return 1
  fi

  echo ${REPO_BASENAME}
}

update_repo(){
 if [ -z "$1" ]; then
    echo "No patch file supplied."
    exit 1
  else
    APP_PATCH_FILE=$1
  fi

 if [ -z "$2" ]; then
    echo "No patch path supplied."
    exit 1
  else
    APP_PATCH_PATH=$2
  fi

  if [ -z "$3" ]; then
    echo "No repo url provided."
    exit 1
  else
    REPO_URL=$3
  fi

  GIT_BRANCH=$(git rev-parse --abbrev-ref HEAD)

  yq "${APP_PATCH_PATH} = \"${REPO_URL}\"" -i ${APP_PATCH_FILE}

  git add ${APP_PATCH_FILE}
  git commit -m "automatic update to repo by bootstrap script"
  git push origin ${GIT_BRANCH}
}

update_configmap_repo(){
  if [ -z "$1" ]; then
    echo "No kustomization file supplied."
    exit 1
  else
    KUSTOMIZATION_FILE=$1
  fi

  if [ -z "$2" ]; then
    echo "No repo URL provided."
    exit 1
  else
    REPO_URL=$2
  fi

  echo "Updating ${KUSTOMIZATION_FILE}..."

  # Update the repoURL literal in the configMapGenerator
  sed_edit_inplace "s|      - repoURL=.*|      - repoURL=${REPO_URL}|" "${KUSTOMIZATION_FILE}"

  GIT_BRANCH=$(git rev-parse --abbrev-ref HEAD)

  git add "${KUSTOMIZATION_FILE}"
  git commit -m "Update repository URL to ${REPO_URL} (automatic update by bootstrap script)"
  git push origin ${GIT_BRANCH}

  echo "✅ Updated repository URL to ${REPO_URL}"
}

update_configmap_branch(){
  if [ -z "$1" ]; then
    echo "No kustomization file supplied."
    exit 1
  else
    KUSTOMIZATION_FILE=$1
  fi

  if [ -z "$2" ]; then
    echo "No branch provided."
    exit 1
  else
    BRANCH=$2
  fi

  echo "Updating ${KUSTOMIZATION_FILE}..."

  # Update the targetRevision literal in the configMapGenerator
  sed_edit_inplace "s|      - targetRevision=.*|      - targetRevision=${BRANCH}|" "${KUSTOMIZATION_FILE}"

  git add "${KUSTOMIZATION_FILE}"
  git commit -m "Update branch to ${BRANCH} (automatic update by bootstrap script)"
  git push origin ${BRANCH}

  echo "✅ Updated branch to ${BRANCH}"
}

check_repo(){
  # New: Read from cluster overlay's configMapGenerator instead of base Application
  CLUSTER_KUSTOMIZATION="./clusters/overlays/${bootstrap_dir}/kustomization.yaml"

  if ! command -v yq &> /dev/null; then
    echo "yq could not be found.  We are unable to verify the repo."
  else

    GIT_REPO=$(git config --get remote.origin.url)
    if ! GIT_REPO_BASENAME=$(get_git_basename ${GIT_REPO}); then
      print_warning "Unable to parse your git remote (${GIT_REPO}). Skipping repo URL check."
      return
    fi

    # Extract repoURL from configMapGenerator literal
    OVERLAY_REPO=$(yq -r '.configMapGenerator[] | select(.name == "gitops-repo-config") | .literals[]' ${CLUSTER_KUSTOMIZATION} | grep "^repoURL=" | cut -d= -f2)
    if ! OVERLAY_REPO_BASENAME=$(get_git_basename ${OVERLAY_REPO}); then
      print_warning "Unable to parse the repo URL in ${CLUSTER_KUSTOMIZATION} (${OVERLAY_REPO}). Skipping repo URL check."
      return
    fi

    if [[ ${GIT_REPO_BASENAME} == ${OVERLAY_REPO_BASENAME} ]] ; then
      echo "Your working repo ${GIT_REPO}, matches your cluster overlay repo ${OVERLAY_REPO}"
    else

      GITHUB_URL="https://github.com/${GIT_REPO_BASENAME}.git"

      echo
      echo "Your current working repo is"
      echo "  ${GIT_REPO}"
      echo
      echo "Your cluster overlay repo is"
      echo "  ${OVERLAY_REPO}"

      if [[ ${FORCE} == "true" ]] ; then
        echo "Updating to ${GITHUB_URL}"
        update_configmap_repo ${CLUSTER_KUSTOMIZATION} ${GITHUB_URL}
      else

        echo
        echo "Do you wish to update it to the following?"
        echo "  ${GITHUB_URL}"
        echo

        PS3="Please enter a number to select: "

        select yn in "Yes" "No"; do
            case $yn in
                Yes ) update_configmap_repo ${CLUSTER_KUSTOMIZATION} ${GITHUB_URL}; break;;
                No ) break;;
            esac
        done
      fi
    fi
  fi
}

patch_file () {
  APP_PATCH_FILE=$1
  NEW_VALUE=$2
  YQ_PATH=$3

  CURRENT_VALUE=$(yq -r ${YQ_PATH} ${APP_PATCH_FILE})

  if [[ ${CURRENT_VALUE} == ${NEW_VALUE} ]]; then
    echo "${APP_PATCH_FILE} already has value ${NEW_VALUE}"
    return
  fi

  yq "${YQ_PATH} = \"${NEW_VALUE}\"" -i ${APP_PATCH_FILE}
}
