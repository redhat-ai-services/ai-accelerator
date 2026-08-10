# disable-gaudi-runtimes

## Purpose

This component disables Intel Gaudi serving runtimes in the OpenShift AI dashboard by adding them to `spec.templateDisablement` on the `OdhDashboardConfig`. Use this on NVIDIA-focused clusters where Gaudi runtimes should not appear as selectable serving templates.

Disabled runtimes:
- `vllm-gaudi-runtime`

## Usage

This component can be added to a base by adding the `components` section to your overlay `kustomization.yaml` file:

```yaml
apiVersion: kustomize.config.k8s.io/v1beta1
kind: Kustomization

resources:
  - ../../base

components:
  - ../../components/disable-gaudi-runtimes
```

This component can be combined with other `disable-*-runtimes` components. Each appends to `templateDisablement` rather than replacing it.
