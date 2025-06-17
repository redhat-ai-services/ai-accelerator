# dashboard-feature-model-catalog

## Purpose
This component is designed to enable the Model Catalog feature.

https://docs.redhat.com/en/documentation/red_hat_openshift_ai_self-managed/2.20/html/configuring_the_model_registry_component/enabling-the-model-catalog_model-registry-config

As of OpenShift AI 2.20, this feature is Tech Preview.

## Prerequisite

The model catalog requires the Model Registry to be enabled.

## Usage

This component can be added to a base by adding the `components` section to your overlay `kustomization.yaml` file:

```
apiVersion: kustomize.config.k8s.io/v1beta1
kind: Kustomization

resources:
  - ../../base

components:
  - ../../components/dashboard-feature-model-catalog
```
