# components-aigateway-maas

## Purpose

This component enables AI Gateway Models-as-a-Service (MaaS) in the DataScienceCluster. MaaS provides a simplified model serving experience with automatic Gateway configuration for inference endpoints.

This component includes:
- Enables `aigateway.modelsAsAService` in the DataScienceCluster
- Creates a Gateway resource in the `openshift-ingress` namespace using the `data-science-gateway-class`

## Prerequisites

This component requires the `data-science-gateway-class` GatewayClass to be configured.

## Usage

This component can be added to a base by adding the `components` section to your overlay `kustomization.yaml` file:

```yaml
apiVersion: kustomize.config.k8s.io/v1beta1
kind: Kustomization

resources:
  - ../../base

components:
  - ../../components/components-aigateway-maas
```
