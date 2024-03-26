#!/bin/bash
set -e

# shellcheck source=/dev/null
source "$(dirname "$0")/functions.sh"

LANG=C
TIMEOUT_SECONDS=45
ARGO_NS="openshift-gitops"
GITOPS_OVERLAY=components/operators/openshift-gitops/operator/overlays/latest/

install_gitops(){
  echo ""
  echo "Installing GitOps Operator."

  kustomize build ${GITOPS_OVERLAY} | oc apply -f -

  # oc wait docs:
  # https://docs.openshift.com/container-platform/4.11/cli_reference/openshift_cli/developer-cli-commands.html#oc-wait
  #
  # kubectl wait docs:
  # https://kubernetes.io/docs/reference/generated/kubectl/kubectl-commands#wait

  echo "Waiting for deployment of the openshift-gitops-operator-controller-manager to begin..."
  until oc get deployment openshift-gitops-operator-controller-manager -n openshift-operators
  do
    sleep 5
  done

  echo "Waiting for openshift-gitops-operator-controller-manager to start..."
  oc wait --for=condition=Available deployment/openshift-gitops-operator-controller-manager -n openshift-operators --timeout=${TIMEOUT_SECONDS}s

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
check_bin kubeseal
check_oc_login

# Verify sealed secrets
#check_sealed_secret

# Execute bootstrap functions
install_gitops
bootstrap_cluster
