#!/usr/bin/env bash
# shellcheck disable=SC1091

set -e

ocp_aws_cluster(){
  TARGET_NS=kube-system
  OBJ=secret/aws-creds
  echo "Checking if ${OBJ} exists in ${TARGET_NS} namespace"
  oc -n "${TARGET_NS}" get "${OBJ}" -o name > /dev/null 2>&1 || return 1
  echo "AWS cluster detected"
}

ocp_aws_create_gpu_machineset(){
  # https://aws.amazon.com/ec2/instance-types/g4
  # single gpu: g4dn.{2,4,8,16}xlarge
  # multi gpu:  g4dn.12xlarge
  # practical:  g4ad.4xlarge
  # a100 (MIG): p4d.24xlarge
  # h100 (MIG): p5.48xlarge

  # https://aws.amazon.com/ec2/instance-types/dl1
  # 8 x gaudi:  dl1.24xlarge

  INSTANCE_TYPE=${1:-g4dn.4xlarge}

  ocp_aws_clone_machineset "${INSTANCE_TYPE}"

  MACHINE_SET_TYPE=$(oc -n openshift-machine-api get machinesets.machine.openshift.io -o name | grep "${INSTANCE_TYPE%.*}" | head -n1)

  PATCH_FILE="$(dirname "$0")/machineset-patch.yaml"

  if [ -f ${PATCH_FILE} ]; then
    echo "Patching ${MACHINE_SET_TYPE} with ${PATCH_FILE}."
    oc -n openshift-machine-api \
      patch "${MACHINE_SET_TYPE}" \
      --type=merge --patch-file ${PATCH_FILE}
  else
    echo "Unable to taint nodes, patch file ${PATCH_FILE} not found."
    exit 1
  fi
 
  oc -n openshift-machine-api \
    patch "${MACHINE_SET_TYPE}" \
    --type=merge --patch '{"spec":{"template":{"spec":{"providerSpec":{"value":{"instanceType":"'"${INSTANCE_TYPE}"'"}}}}}}'
}

ocp_aws_clone_machineset(){
  [ -z "${1}" ] && \
  echo "
    usage: ocp_aws_create_gpu_machineset < instance type, default g4dn.4xlarge >
  "

  INSTANCE_TYPE=${1:-g4dn.4xlarge}
  MACHINE_SET=$(oc -n openshift-machine-api get machinesets.machine.openshift.io -o name | grep worker | head -n1)

  # check for an existing instance machine set
  if oc -n openshift-machine-api get machinesets.machine.openshift.io -o name | grep -q "${INSTANCE_TYPE%.*}"; then
    echo "Exists: machineset - ${INSTANCE_TYPE}"
  else
    echo "Creating: machineset - ${INSTANCE_TYPE}"
    oc -n openshift-machine-api \
      get "${MACHINE_SET}" -o yaml | \
        sed '/machine/ s/-worker/-'"${INSTANCE_TYPE}"'/g
          /name/ s/-worker/-'"${INSTANCE_TYPE%.*}"'/g
          s/instanceType.*/instanceType: '"${INSTANCE_TYPE}"'/
          s/replicas.*/replicas: 0/' | \
      oc apply -f -
  fi
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

INSTANCE_TYPE=${INSTANCE_TYPE:-g4dn.4xlarge}

ocp_aws_cluster || exit 0
ocp_aws_create_gpu_machineset ${INSTANCE_TYPE}
ocp_create_machineset_autoscale
