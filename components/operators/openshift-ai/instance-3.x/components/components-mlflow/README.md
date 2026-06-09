# components-mlflow

## Purpose

This component enables the MLFlow Operator in the DataScienceCluster. MLFlow is used for experiment tracking in your AI Pipelines.

## Usage

This component can be added to a base by adding the `components` section to your overlay `kustomization.yaml` file:

```yaml
apiVersion: kustomize.config.k8s.io/v1beta1
kind: Kustomization

resources:
  - ../../base

components:
  - ../../components/components-mlflow
```
