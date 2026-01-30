# hardware-profiles-cpu

> [!WARNING]  
> Hardware profiles in 2.22 utilize the `dashboard.opendatahub.io/v1alpha1` API version and 2.23+ migrated to `infrastructure.opendatahub.io/v1alpha1`.

## Purpose
This component is designed help admins configure a hardware profile with cpu.

For more information on accelerators, please see the [Working with hardware profiles](https://docs.redhat.com/en/documentation/red_hat_openshift_ai_self-managed/2-latest/html/working_with_accelerators/working-with-hardware-profiles_accelerators#working-with-hardware-profiles_accelerators) documentation.

## Usage

This component can be added to a base by adding the `components` section to your overlay `kustomization.yaml` file:

```
apiVersion: kustomize.config.k8s.io/v1beta1
kind: Kustomization

resources:
  - ../../base

components:
  - ../../components/hardware-profiles-cpu
```
