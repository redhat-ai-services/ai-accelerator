#!/bin/bash
set -e

# 8 seconds is usually enough time for the average user to realize they foobar
export SLEEP_SECONDS=8

################# start standard init #################

check_shell(){
  [ -n "$BASH_VERSION" ] && return
  echo "Please verify you are running in bash shell"
  sleep "${SLEEP_SECONDS:-8}"
}

check_git_root(){
  if [ -d .git ] && [ -d scripts ]; then
    GIT_ROOT=$(pwd)
    export GIT_ROOT
    echo "GIT_ROOT: ${GIT_ROOT}"
  else
    echo "Please run this script from the root of the git repo"
    exit
  fi
}

get_script_path(){
  SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )
  echo "SCRIPT_DIR: ${SCRIPT_DIR}"
}

check_shell
check_git_root
get_script_path

################# end standard init #################

is_sourced() {
  if [ -n "$ZSH_VERSION" ]; then
      case $ZSH_EVAL_CONTEXT in *:file:*) return 0;; esac
  else  # Add additional POSIX-compatible shell names here, if needed.
      case ${0##*/} in dash|-dash|bash|-bash|ksh|-ksh|sh|-sh) return 0;; esac
  fi
  return 1  # NOT sourced.
}

ocp_check_login(){
  oc cluster-info | head -n1
  oc whoami || exit 1
  echo
}

ocp_check_info(){
  ocp_check_login

  echo "NAMESPACE: $(oc project -q)"
  sleep "${SLEEP_SECONDS:-8}"
}

apply_firmly(){
  if [ ! -f "${1}/kustomization.yaml" ]; then
    echo "Please provide a dir with \"kustomization.yaml\""
    return 1
  fi

  until_true oc apply -k "${1}" 2>/dev/null
}

until_true(){
  echo "Running:" "${@}"
  until "${@}" 1>&2
  do
    echo "again..."
    sleep 20
  done

  echo "[OK]"
}

ocp_control_nodes_not_schedulable(){
  oc patch schedulers.config.openshift.io/cluster --type merge --patch '{"spec":{"mastersSchedulable": false}}'
}

ocp_control_nodes_schedulable(){
  oc patch schedulers.config.openshift.io/cluster --type merge --patch '{"spec":{"mastersSchedulable": true}}'
}

ocp_aws_create_gpu_machineset(){
  # https://aws.amazon.com/ec2/instance-types/g4
  # single gpu: g4dn.{2,4,8,16}xlarge
  # multi gpu: g4dn.12xlarge
  # cheapest: g4ad.4xlarge
  # a100 (MIG): p4d.24xlarge
  # h100 (MIG): p5.48xlarge
  INSTANCE_TYPE=${1:-g4dn.4xlarge}
  MACHINE_SET=${2:-$(oc -n openshift-machine-api get machinesets.machine.openshift.io -o name | grep worker | head -n1)}

  echo "MACHINE_SET: ${MACHINE_SET}"

  # check for an existing gpu machine set
  oc -n openshift-machine-api get machinesets.machine.openshift.io -o name | grep gpu || \
    oc -n openshift-machine-api get "${MACHINE_SET}" -o yaml | \
      sed '/machine/ s/-worker/-gpu/g
        /name/ s/-worker/-gpu/g
        s/instanceType.*/instanceType: '"${INSTANCE_TYPE}"'/
        s/replicas.*/replicas: 0/' | \
      oc apply -f -

  MACHINE_SET_GPU=$(oc -n openshift-machine-api get machinesets.machine.openshift.io -o name | grep gpu | head -n1)

  # cosmetic
  oc -n openshift-machine-api \
    patch "${MACHINE_SET_GPU}" \
    --type=merge --patch '{"spec":{"template":{"spec":{"metadata":{"labels":{"node-role.kubernetes.io/gpu":""}}}}}}'

  # should help auto provisioner
  oc -n openshift-machine-api \
    patch "${MACHINE_SET_GPU}" \
    --type=merge --patch '{"spec":{"template":{"spec":{"metadata":{"labels":{"cluster-api/accelerator":"nvidia-gpu"}}}}}}'
  
    oc -n openshift-machine-api \
    patch "${MACHINE_SET_GPU}" \
    --type=merge --patch '{"metadata":{"labels":{"cluster-api/accelerator":"nvidia-gpu"}}}'
  
  oc -n openshift-machine-api \
    patch "${MACHINE_SET_GPU}" \
    --type=merge --patch '{"spec":{"template":{"spec":{"providerSpec":{"value":{"instanceType":"'"${INSTANCE_TYPE}"'"}}}}}}'
  
}

ocp_create_machineset_autoscale(){
  MACHINE_MIN=${1:-0}
  MACHINE_MAX=${2:-4}
  MACHINE_SETS=${3:-$(oc -n openshift-machine-api get machinesets.machine.openshift.io -o name | sed 's@.*/@@' )}

  for set in ${MACHINE_SETS}
  do
cat << YAML | oc apply -f -
apiVersion: "autoscaling.openshift.io/v1beta1"
kind: "MachineAutoscaler"
metadata:
  name: "${set}"
  namespace: "openshift-machine-api"
spec:
  minReplicas: ${MACHINE_MIN}
  maxReplicas: ${MACHINE_MAX}
  scaleTargetRef:
    apiVersion: machine.openshift.io/v1beta1
    kind: MachineSet
    name: "${set}"
YAML
  done
}

ocp_scale_machineset(){
  REPLICAS=${1:-1}
  MACHINE_SETS=${2:-$(oc -n openshift-machine-api get machineset -o name)}

  # scale workers
  echo "${MACHINE_SETS}" | \
    xargs \
      oc -n openshift-machine-api \
      scale --replicas="${REPLICAS}"
}

nvidia_setup_dashboard_monitor(){
  curl -sLfO https://github.com/NVIDIA/dcgm-exporter/raw/main/grafana/dcgm-exporter-dashboard.json
  oc create configmap nvidia-dcgm-exporter-dashboard -n openshift-config-managed --from-file=dcgm-exporter-dashboard.json || true
  oc label configmap nvidia-dcgm-exporter-dashboard -n openshift-config-managed "console.openshift.io/dashboard=true" --overwrite
  oc label configmap nvidia-dcgm-exporter-dashboard -n openshift-config-managed "console.openshift.io/odc-dashboard=true" --overwrite
  oc -n openshift-config-managed get cm nvidia-dcgm-exporter-dashboard --show-labels
  rm dcgm-exporter-dashboard.json
}

nvidia_setup_dashboard_admin(){
  helm repo add rh-ecosystem-edge https://rh-ecosystem-edge.github.io/console-plugin-nvidia-gpu || true
  helm repo update > /dev/null 2>&1
  helm upgrade --install -n nvidia-gpu-operator console-plugin-nvidia-gpu rh-ecosystem-edge/console-plugin-nvidia-gpu > /dev/null 2>&1

  if oc get consoles.operator.openshift.io cluster --output=jsonpath="{.spec.plugins}" >/dev/null; then
    oc patch consoles.operator.openshift.io cluster --patch '{ "spec": { "plugins": ["console-plugin-nvidia-gpu"] } }' --type=merge
  else
    oc get consoles.operator.openshift.io cluster --output=jsonpath="{.spec.plugins}" | grep -q console-plugin-nvidia-gpu || \
      oc patch consoles.operator.openshift.io cluster --patch '[{"op": "add", "path": "/spec/plugins/-", "value": "console-plugin-nvidia-gpu" }]' --type=json
  fi

  oc patch clusterpolicies.nvidia.com gpu-cluster-policy --patch '{ "spec": { "dcgmExporter": { "config": { "name": "console-plugin-nvidia-gpu" } } } }' --type=merge
  oc -n nvidia-gpu-operator get deploy -l app.kubernetes.io/name=console-plugin-nvidia-gpu
}

nvidia_setup_mig_config(){
  MIG_MODE=${1:-single}
  MIG_CONFIG=${1:-all-1g.5gb}

  ocp_aws_create_gpu_machineset p4d.24xlarge "$(oc -n openshift-machine-api get machinesets.machine.openshift.io -o name | grep worker | grep east-2b | head -n1)"

  oc apply -k components/operators/gpu-operator-certified/instance/overlays/mig-"${MIG_MODE}"

  MACHINE_SET_GPU=$(oc -n openshift-machine-api get machinesets.machine.openshift.io -o name | grep gpu | head -n1)

  oc -n openshift-machine-api \
    patch "${MACHINE_SET_GPU}" \
    --type=merge --patch '{"spec":{"template":{"spec":{"metadata":{"labels":{"nvidia.com/mig.config":"'"${MIG_CONFIG}"'"}}}}}}'

}

ocp_aws_cluster_autoscaling(){
  oc apply -k components/configs/autoscale/overlays/gpus-accelerator-label

  ocp_aws_create_gpu_machineset g4dn.4xlarge
  ocp_create_machineset_autoscale 0 3

  ocp_control_nodes_schedulable

  # scale workers to 1
  WORKER_MS="$(oc -n openshift-machine-api get machineset -o name | grep worker)"
  ocp_scale_machineset 1 "${WORKER_MS}"
}

setup_operator_devspaces(){
  apply_firmly components/operators/devspaces/aggregate/overlays/default
}

################ demo functions ################

check_cluster_version(){
  OCP_VERSION=$(oc version | sed -n '/Server Version: / s/Server Version: //p')
  AVOID_VERSIONS=()
  TESTED_VERSIONS=("4.12.12" "4.12.33" "4.13.13")

  echo "Current OCP version: ${OCP_VERSION}"
  echo "Tested OCP version(s): ${TESTED_VERSIONS[*]}"
  echo ""

  # shellcheck disable=SC2076
  if [[ " ${AVOID_VERSIONS[*]} " =~ " ${OCP_VERSION} " ]]; then
    echo "OCP version ${OCP_VERSION} is known to have issues with this demo"
    echo ""
    echo 'Recommend: "oc adm upgrade --to-latest=true"'
    echo ""
  fi
}

################## main area ###################

usage(){
  # tell us something useful
  echo "
  Run the following to setup autoscaling in AWS:  
  . scripts/bootstrap.sh && ocp_aws_cluster_autoscaling

  Run the following to setup devspaces:
  . scripts/bootstrap.sh && setup_operator_devspaces

  "
}

setup_demo(){
  check_shell
  check_cluster_version
  apply_firmly components
  usage
}

is_sourced && check_shell && return

ocp_check_login

setup_demo
