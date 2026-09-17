# components-mcplifecycle

## Purpose

This component enables the MCP Lifecycle Operator and the AI Hub MCP Catalog in Red Hat OpenShift AI.

The MCP Lifecycle Operator manages deployment and lifecycle of Model Context Protocol (MCP) servers. When enabled, it watches `MCPServer` custom resources and provisions the Deployments, Services, NetworkPolicies, and cluster-internal URLs needed for service discovery. Developers can then deploy and manage MCP servers from the AI Hub MCP Catalog without writing Kubernetes manifests or sourcing container images manually.

> **Note:** The MCP Lifecycle Operator is a Technology Preview feature in OpenShift AI 3.5. Technology Preview features are not supported with Red Hat production SLAs and might not be functionally complete. See [Technology Preview Features Support Scope](https://access.redhat.com/support/offerings/techpreview).

## Prerequisites

- Red Hat OpenShift AI 3.5 (or later) on a supported OpenShift cluster
- Optional: [MCP gateway Operator](https://docs.redhat.com/en/documentation/red_hat_openshift_ai_self-managed/3.5/html-single/working_with_the_mcp_catalog/index#mcp-gateway-operator-overview_mcp-gateway) if your deployment needs centralized MCP routing and access control. The gateway is a separate install (part of Red Hat Connectivity Link) and is not installed by this component.

## Usage

This component can be added to a base by adding the `components` section to your overlay `kustomization.yaml` file:

```yaml
apiVersion: kustomize.config.k8s.io/v1beta1
kind: Kustomization

resources:
  - ../../base

components:
  - ../../components/components-mcplifecycle
```
