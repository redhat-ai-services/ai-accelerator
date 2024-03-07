# Demo GPUs on OpenShift

Setup Nvidia GPUs on OpenShift with ease. This repo is intended as a foundation for GPU workloads on OpenShift.

Initially `bootstrap.sh` configures GPU time-slicing which allows 2 workloads
to share a single GPU.

## In addition

- Try out GPUs in OpenShift Dev Spaces via this [devfile.yaml](devfile.yaml)
- Run [jupyter notebooks](notebooks) with [pytorch](notebooks/00-test-gpu-torch.ipynb)
or [tensorflow](notebooks/00-test-gpu-tensorflow.ipynb)

The [components](components) folder is intended for reuse with ArgoCD or OpenShift GitOps.
Familiarity with Kustomize will be helpful. This folder contains various ~~secret~~ recipes for `oc apply -k`.

## Prerequisites

- Nvidia GPU hardware or cloud provider with GPU instances
- OpenShift 4.11+ w/ cluster admin
- [Internet access](TODO.md)
- AWS (auto scaling, optional)
- OpenShift Dev Spaces 3.8.0+ (optional)

[Red Hat Demo Platform](https://demo.redhat.com) Options (Tested)

- <a href="https://demo.redhat.com/catalog?item=babylon-catalog-prod/sandboxes-gpte.sandbox-ocp.prod&utm_source=webapp&utm_medium=share-link" target="_blank">AWS with OpenShift Open Environment</a>
  - 1 x Control Plane - `m5.4xlarge`
  - 0 x Workers - `m5.2xlarge`
- <a href="https://demo.redhat.com/catalog?item=babylon-catalog-prod/community-content.com-mlops-wksp.prod&utm_source=webapp&utm_medium=share-link" target="_blank">MLOps Demo: Data Science & Edge Practice</a>

## Quickstart

Setup cluster GPU operators

```
scripts/bootstrap.sh
```

## Various Commands

AWS autoscaling w/ OpenShift Dev Spaces

*NOTE: GPU nodes may take 10 - 15 mins to become available*

```
# aws gpu - load functions
. scripts/bootstrap.sh

# aws gpu - basic gpu autoscaling
ocp_aws_cluster_autoscaling

# deploy devspaces
setup_operator_devspaces
```

Deploy GPU test pod

```
oc apply -f https://raw.githubusercontent.com/NVIDIA/gpu-operator/master/tests/gpu-pod.yaml
```

Setup Time Slicing (2x)

```
oc apply -k components/operators/gpu-operator-certified/instance/overlays/time-sliced-2
```

Request / Test a GPU workload of 6 GPUs

```
oc apply -k components/demos/nvidia-gpu-verification/overlays/toleration-replicas-6

# check the number of pods
oc -n nvidia-gpu-verification get pods
```

Get GPU nodes

```
oc get nodes -l node-role.kubernetes.io/gpu

oc get nodes \
  -l node-role.kubernetes.io/gpu \
  -o jsonpath={.items[*].status.allocatable} | jq . | grep nvidia
```

Watch cluster autoscaler logs

```
oc -n openshift-machine-api logs -f deploy/cluster-autoscaler-default
```

Manually label nodes as GPU (optional)

```
NODE=worker1.ocp.run
  oc label node/${NODE} --overwrite "node-role.kubernetes.io/gpu="
```

## Other Instructions

[Nvidia Multi Instance GPU (MIG) on OpenShift](MIG.md)

## Links

- [Additional Notes](components/operators/gpu-operator-certified/instance/INFO.md)
- [Docs - AWS GPU Instances](https://aws.amazon.com/ec2/instance-types/#Accelerated_Computing)
- [Docs - Nvidia GPU Operator on Openshift](https://docs.nvidia.com/datacenter/cloud-native/gpu-operator/latest/openshift/contents.html)
- [Docs - Nvidia GPU admin dashboard](https://docs.openshift.com/container-platform/4.11/monitoring/nvidia-gpu-admin-dashboard.html)
- [Docs - Multi Instance GPU (MIG) in OCP](https://docs.nvidia.com/datacenter/cloud-native/gpu-operator/latest/openshift/mig-ocp.html)
- [Docs - Time Slicing in OCP](https://docs.nvidia.com/datacenter/cloud-native/gpu-operator/latest/openshift/time-slicing-gpus-in-openshift.html)
- [Docs - KB GPU Autoscaling](https://access.redhat.com/solutions/6055181)
  - [Docs - cluster-api/accelerator label](https://bugzilla.redhat.com/show_bug.cgi?id=1943194#c85)
- [Blog - RH Nvidia GPUs on OpenShift](https://cloud.redhat.com/blog/autoscaling-nvidia-gpus-on-red-hat-openshift)
- [Demo - bkoz GPU DevSpaces](https://github.com/bkoz/devspaces)
- [GPU Operator default config map](https://gitlab.com/nvidia/kubernetes/gpu-operator/-/blob/v23.6.1/assets/state-mig-manager/0400_configmap.yaml?ref_type=tags)

## Container License

`udi-cuda` images from [HERE](https://github.com/redhat-na-ssa/demo-ocp-gpu/pkgs/container/udi-cuda) are based on [official NVIDIA CUDA images](https://hub.docker.com/r/nvidia/cuda).

Please be aware of any of the associated terms and conditions.

```
This container image and its contents are governed by the NVIDIA Deep Learning Container License.

By pulling and using the container, you accept the terms and conditions of this license:
https://developer.nvidia.com/ngc/nvidia-deep-learning-container-license

A copy of this license is made available in this container at /NGC-DL-CONTAINER-LICENSE for your convenience.
```
