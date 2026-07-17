# components-mlflow

## Purpose

This component enables the MLflow Operator in the DataScienceCluster. MLflow is an open-source platform for managing the machine learning lifecycle, including experiment tracking, model packaging, and model registry.

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
