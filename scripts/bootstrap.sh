#!/bin/bash
set -e

# shellcheck source=/dev/null
source "$(dirname "$0")/functions.sh"

LANG=C
TIMEOUT_SECONDS=45
OPERATOR_NS="openshift-gitops-operator"
ARGO_NS="openshift-gitops"
GITOPS_OVERLAY=components/operators/openshift-gitops/operator/overlays/latest/

YAML_FILE="./components/argocd/apps/base/cluster-config-app-of-apps.yaml"


confirm_repo_update(){

REPO_URL=$(yq eval '.spec.source.repoURL' "$YAML_FILE")
REPO_REVISION=$(yq eval '.spec.source.targetRevision' "$YAML_FILE")

# Get the current working repo URL (from the 'origin' remote)
WORKING_REPO_URL=$(git remote get-url origin)
# Get the current working repo branch
WORKING_REPO_REVISION=$(git rev-parse --abbrev-ref HEAD) 

if [[ "$REPO_URL" != "$WORKING_REPO_URL" ]] || [[ "$REPO_REVISION" != "$WORKING_REPO_REVISION" ]]; then

  # Prompt the user for a new Repo, defaulting to the gitops configured repo if no input is given
  read -p "Your GitOps process is currently configured to use the repository $REPO_URL on branch $REPO_REVISION, 
  but your current working repository is $WORKING_REPO_URL on branch $WORKING_REPO_REVISION. 
  Do you want to reconfigure the GitOps process to use the current working repository? (Y/N): N " USER_CHOICE

  echo "You selected" $USER_CHOICE
  # Use the old URL if no new URL is provided
  if [[ -z "$USER_CHOICE" ]] || ([[ "$USER_CHOICE" != 'y' ]] && [[ "$USER_CHOICE" != 'Y' ]]); then
      echo "No change in repository proceed with default option"
  else
      echo "updaing working repository"
      yq eval ".spec.source.repoURL = \"$WORKING_REPO_URL\"" -i "$YAML_FILE"
      yq eval ".spec.source.targetRevision = \"$WORKING_REPO_REVISION\"" -i "$YAML_FILE"

      git add "$YAML_FILE"
      git commit -m "updated by bootstrap process" --  "$YAML_FILE"
      git push origin "$WORKING_REPO_REVISION"
  fi
else
  echo "No mismatch in repository"
fi

}

apply_firmly(){
  if [ ! -f "${1}/kustomization.yaml" ]; then
    echo "Please provide a dir with \"kustomization.yaml\""
    return 1
  fi

  # kludge
  until oc kustomize "${1}" --enable-helm | oc apply -f- 2>/dev/null
  do
    echo "again..."
    sleep 20
  done
  # until_true oc apply -k "${1}" 2>/dev/null
}

install_gitops(){
  echo ""
  echo "Installing GitOps Operator."

  apply_firmly ${GITOPS_OVERLAY} 

  # oc wait docs:
  # https://docs.openshift.com/container-platform/4.11/cli_reference/openshift_cli/developer-cli-commands.html#oc-wait
  #
  # kubectl wait docs:
  # https://kubernetes.io/docs/reference/generated/kubectl/kubectl-commands#wait

  echo "Waiting for deployment of the openshift-gitops-operator-controller-manager to begin..."
  until oc get deployment openshift-gitops-operator-controller-manager -n ${OPERATOR_NS}
  do
    sleep 5
  done

  echo "Waiting for openshift-gitops-operator-controller-manager to start..."
  oc wait --for=condition=Available deployment/openshift-gitops-operator-controller-manager -n ${OPERATOR_NS} --timeout=${TIMEOUT_SECONDS}s

  echo "Waiting for ${ARGO_NS} namespace to be created..."
  oc wait --for=jsonpath='{.status.phase}'=Active namespace/${ARGO_NS} --timeout=${TIMEOUT_SECONDS}s

  echo "Waiting for deployments to start..."
  oc wait --for=condition=Available deployment/cluster -n ${ARGO_NS} --timeout=${TIMEOUT_SECONDS}s

  wait_for_openshift_gitops

  echo ""
  echo "OpenShift GitOps successfully installed."
}



bootstrap_cluster(){

  PS3="Please enter a number to select a bootstrap folder: "
  
  select bootstrap_dir in bootstrap/overlays/*/; 
  do
      test -n "$bootstrap_dir" && break;
      echo ">>> Invalid Selection";
  done

  echo
  echo "Selected: ${bootstrap_dir}"
  echo

  check_branch $(basename ${bootstrap_dir})
  
  echo "Apply overlay to override default instance"
  kustomize build "${bootstrap_dir}" | oc apply -f -

  wait_for_openshift_gitops

  echo
  echo "Restart the application-controller to start the sync"
  # Restart is necessary to resolve a bug where apps don't start syncing after they are applied
  oc delete pods -l app.kubernetes.io/name=openshift-gitops-application-controller -n ${ARGO_NS}

  wait_for_openshift_gitops

  route=$(oc get route openshift-gitops-server -o jsonpath='{.spec.host}' -n ${ARGO_NS})
  echo
  echo "GitOps has successfully deployed!  Check the status of the sync here:"
  echo "https://${route}"
}

# Verify CLI tooling
setup_bin
check_bin oc
check_bin kustomize
# check_bin kubeseal
check_oc_login

# Verify sealed secrets
#check_sealed_secret

# Execute bootstrap functions
confirm_repo_update
install_gitops
bootstrap_cluster