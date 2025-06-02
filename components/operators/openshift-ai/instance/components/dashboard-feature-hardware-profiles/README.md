# dashboard-feature-hardware-profiles

## Purpose
This component is designed enable Hardware Profiles, a replacement for Accelerator Profiles.

https://docs.redhat.com/en/documentation/red_hat_openshift_ai_self-managed/2.19/html/working_with_accelerators/working-with-hardware-profiles_accelerators

As of OpenShift 2.19, this feature is Tech Preview

## Usage

This component can be added to a base by adding the `components` section to your overlay `kustomization.yaml` file:

```
apiVersion: kustomize.config.k8s.io/v1beta1
kind: Kustomization

resources:
  - ../../base

components:
  - ../../components/dashboard-feature-hardware-profiles
```
