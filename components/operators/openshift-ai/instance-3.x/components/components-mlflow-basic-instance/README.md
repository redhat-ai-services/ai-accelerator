# components-mlflow-basic-instance

## Purpose

This component deploys a cluster-scoped `MLflow` custom resource for a minimal development or test deployment. OpenShift AI supports a single shared MLflow instance per cluster, created in the `redhat-ods-applications` namespace.

The instance uses:
- SQLite for the backend store (`sqlite:////mlflow/mlflow.db`)
- A 10Gi PVC with `ReadWriteOnce` for file-based artifact storage
- Artifact serving enabled through the MLflow server REST API

This configuration matches the [minimal development or test deployment](https://docs.redhat.com/en/documentation/red_hat_openshift_ai_self-managed/3.4/html-single/working_with_mlflow/index#installing-mlflow_mlflow) from the Red Hat OpenShift AI documentation. For production, use PostgreSQL for metadata and S3-compatible object storage for artifacts instead.

## Prerequisites

- The MLflow Operator component must be enabled in the DataScienceCluster (`components-mlflow`)

## Usage

This component can be added to a base by adding the `components` section to your overlay `kustomization.yaml` file:

```yaml
apiVersion: kustomize.config.k8s.io/v1beta1
kind: Kustomization

resources:
  - ../../base

components:
  - ../../components/components-mlflow
  - ../../components/components-mlflow-basic-instance
```
