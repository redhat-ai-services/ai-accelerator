# aws-gpu-machineset

## Purpose

This component is designed to setup a MachineSet with GPUs on an AWS based OpenShift cluster.

This component triggers a job that creates a MachineSet based on your current MachineSet.

This component has been tested using AWS based OpenShift instances provisioned by demo.redhat.com.

## Usage

This component can be added to a base by adding the `components` section to your overlay `kustomization.yaml` file:

```
apiVersion: kustomize.config.k8s.io/v1beta1
kind: Kustomization

resources:
  - ../../base

components:
  - ../../components/time-sliced
```


You can customize the taint applied to the GPU nodes by updating [machineset-patch.yaml](./machineset-patch.yaml) file.
