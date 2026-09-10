# inference-gateway

## Purpose

This component creates a Kubernetes Gateway resource for inference traffic. The Gateway is configured in the `openshift-ingress` namespace using the `data-science-gateway-class` GatewayClass.

This Gateway allows inference endpoints to be exposed and accessed from outside the cluster. It accepts HTTP traffic on port 80 and routes to services in any namespace.

## Prerequisites

This component requires a GatewayClass named `data-science-gateway-class` to be available in the cluster. This is typically provided by the OpenShift AI operator when KServe is configured.

## Usage

This component can be added to a base by adding the `components` section to your overlay `kustomization.yaml` file:

```yaml
apiVersion: kustomize.config.k8s.io/v1beta1
kind: Kustomization

resources:
  - ../../base

components:
  - ../../components/inference-gateway
```

You can customize the Gateway configuration by modifying the [gateway.yaml](./gateway.yaml) file.
