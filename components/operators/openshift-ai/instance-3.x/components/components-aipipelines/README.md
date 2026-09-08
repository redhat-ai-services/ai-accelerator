# components-aipipelines

## Purpose

This component enables Data Science Pipelines (based on Kubeflow Pipelines) in the DataScienceCluster. Data Science Pipelines allow you to build, deploy, and manage end-to-end machine learning workflows.

## Usage

This component can be added to a base by adding the `components` section to your overlay `kustomization.yaml` file:

```yaml
apiVersion: kustomize.config.k8s.io/v1beta1
kind: Kustomization

resources:
  - ../../base

components:
  - ../../components/components-aipipelines
```
