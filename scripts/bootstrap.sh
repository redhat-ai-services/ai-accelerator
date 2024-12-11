#!/bin/bash
set -e

# Default values
LANG=C
TIMEOUT_SECONDS=45
OPERATOR_NS="openshift-gitops-operator"
ARGO_NS="openshift-gitops"
GITOPS_OVERLAY=components/operators/openshift-gitops/operator/overlays/latest/

# shellcheck source=/dev/null
source "$(dirname "$0")/functions.sh"
source "$(dirname "$0")/util.sh"
source "$(dirname "$0")/command_flags.sh" "$@"

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
    # https://docs.openshift.com/container-platform/latest/cli_reference/openshift_cli/developer-cli-commands.html#oc-wait
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

  while true; do
    read -p "Do you want to configure the platform workloads into the infrastucture nodes[Y/N]: " infra_nodes_answer
    if [[ "$infra_nodes_answer" =~ ^([yY][eE][sS]|[yY])$ ]]; then
      infra_nodes_configuration=1
      break
    elif [[ "$infra_nodes_answer" =~ ^([nN][oO]|[nN])$ ]]; then
      infra_nodes_configuration=0
      break
    else
      echo -e "\nYou must type Y, N, Yes, or No."
    fi
  done
  if [[ $infra_nodes_configuration -eq 1 ]]; then
    base_dir="bootstrap/overlays-infra-nodes"
  else
    base_dir="bootstrap/overlays"
  fi

  # Check if bootstrap_dir is already set
  if [ -n "$BOOTSTRAP_DIR" ]; then
    bootstrap_dir=$BOOTSTRAP_DIR
    test -n "$base_dir/$bootstrap_dir";
    echo "Using bootstrap folder: $bootstrap_dir"
  else
    echo
    PS3="Please enter a number to select a bootstrap folder: "
    
    select bootstrap_dir in $(basename -a $base_dir/*/); 
    do
        test -n "$base_dir/$bootstrap_dir" && break;
        echo ">>> Invalid Selection";
    done

    echo
    echo "Selected: ${bootstrap_dir}"
    echo
  fi

  check_branch
  check_repo
  
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
install_gitops
bootstrap_cluster
