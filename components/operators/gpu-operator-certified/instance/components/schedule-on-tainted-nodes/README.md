# schedule-on-tainted-nodes

## Purpose

This component is designed to allow the GPU Operator DaemonSets to run on tainted GPU nodes.

## Usage

This component can be added to a base by adding the `components` section to your overlay `kustomization.yaml` file:

```
apiVersion: kustomize.config.k8s.io/v1beta1
kind: Kustomization

resources:
  - ../../base

components:
  - ../../components/schedule-on-tainted-nodes
```

To customize the toleration to match your node taints, please update [patch-cluster-policy.yaml](./patch-cluster-policy.yaml)
