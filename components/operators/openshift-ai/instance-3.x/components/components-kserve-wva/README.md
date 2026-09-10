# components-kserve-wva

## Purpose

This component enables the workload variable autoscaling capabilities with KServe and LLMInferenceServices.

## Usage

This component can be added to a base by adding the `components` section to your overlay `kustomization.yaml` file:

```yaml
apiVersion: kustomize.config.k8s.io/v1beta1
kind: Kustomization

resources:
  - ../../base

components:
  - ../../components/components-kserve-wva
```
