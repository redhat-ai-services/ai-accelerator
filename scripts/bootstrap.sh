#!/bin/bash
set -e

# Default values
LANG=C
TIMEOUT_SECONDS=45
OPERATOR_NS="openshift-gitops-operator"
ARGO_NS="openshift-gitops"
GITOPS_OVERLAY=components/operators/openshift-gitops/operator/overlays/latest/

# Default used by child scripts
export OCP_VERSION=4.11

# shellcheck source=/dev/null
source "$(dirname "$0")/functions.sh"
source "$(dirname "$0")/util.sh"
source "$(dirname "$0")/command_flags.sh" "$@"
YAML_FILE="./components/argocd/apps/base/cluster-config-app-of-apps.yaml"

CURRENT_REPO_URL="https://github.com/redhat-ai-services/ai-accelerator.git"
CURRENT_REPO_REVISION="main"
NEW_REPO_URL=""
NEW_REPO_REVISION=""


confirm_repo_update(){

CURRENT_REPO_URL=$(yq eval '.spec.source.repoURL' "$YAML_FILE")
CURRENT_REPO_REVISION=$(yq eval '.spec.source.targetRevision' "$YAML_FILE")


# Prompt the user for a new Repo, defaulting to the old repo if no input is given
read -p "Your environment will be provisioned through ArgoCD using the following Git repo, you can use default (press Enter) or change it:
- Git Repository [$CURRENT_REPO_URL]: " NEW_REPO_URL

read -p "- Git Repository Revision [$CURRENT_REPO_REVISION]: " NEW_REPO_REVISION

echo "User entered rep: $NEW_REPO_URL Revision: $NEW_REPO_REVISION"

# Use the old URL if no new URL is provided
if [ -z "$NEW_REPO_URL" ]; then
    NEW_REPO_URL=$CURRENT_REPO_URL
    echo "No new Repo URL provided. Using the old URL: $CURRENT_REPO_URL"
fi

if [ -z "$NEW_REPO_REVISION" ]; then
    NEW_REPO_REVISION=$CURRENT_REPO_REVISION
    echo "No new Repo Revision provided. Using the old URL: $CURRENT_REPO_REVISION"
fi

if [[ "$CURRENT_REPO_URL" != "$NEW_REPO_URL" ]] || [[ "$CURRENT_REPO_REVISION" != "$NEW_REPO_REVISION" ]]; then
  echo "updating rep: $NEW_REPO_URL Revision: $NEW_REPO_REVISION" in the file $YAML_FILE
  # Use sed to replace the old variables with the new ones in the YAML file
  cp $YAML_FILE $YAML_FILE.bak
  yq eval ".spec.source.repoURL = \"$NEW_REPO_URL\"" -i $YAML_FILE
  yq eval ".spec.source.targetRevision = \"$NEW_REPO_REVISION\"" -i $YAML_FILE
  yq eval 'del(.spec.syncPolicy)' -i $YAML_FILE

fi

}

cleanup_repo_changes(){
  if [[ "$CURRENT_REPO_URL" != "$NEW_REPO_URL" ]] || [[ "$CURRENT_REPO_REVISION" != "$NEW_REPO_REVISION" ]]; then
    mv $YAML_FILE.bak $YAML_FILE
  fi
}

apply_firmly(){
  if [ ! -f "${1}/kustomization.yaml" ]; then
    print_error "Please provide a dir with \"kustomization.yaml\""
    return 1
  fi

  # kludge
  until oc kustomize "${1}" --enable-helm | oc apply -f- 2>/dev/null
  do
    echo -n "."
    sleep 5
  done
  echo ""
  # until_true oc apply -k "${1}" 2>/dev/null
}

install_gitops(){
  echo
  echo "Checking if GitOps Operator is already installed and running"
  if [[ $(oc get pod -n ${OPERATOR_NS} --no-headers -o custom-columns=":status.phase") == "Running" ]]; then
    echo
    echo "GitOps operator is already installed and running"
  else
    echo
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
  fi
}



bootstrap_cluster(){

  base_dir="bootstrap/overlays"

  # Check if bootstrap_dir is already set
  if [ -n "$BOOTSTRAP_DIR" ]; then
    bootstrap_dir=$BOOTSTRAP_DIR
    test -n "$base_dir/$bootstrap_dir";
    echo "Using bootstrap folder: $bootstrap_dir"
  else
    PS3="Please enter a number to select a bootstrap folder: "
    
    select bootstrap_dir in $(basename -a $base_dir/*/); 
    do
        test -n "$base_dir/$bootstrap_dir" && break;
        echo ">>> Invalid Selection";
    done

  check_branch $(basename ${bootstrap_dir})
  check_repo $(basename ${bootstrap_dir})
  
  echo "Apply overlay to override default instance"
  kustomize build "${base_dir}/${bootstrap_dir}" | oc apply -f -

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
cleanup_repo_changes