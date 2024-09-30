# schedule-on-tainted-nodes

## Purpose

This component is designed to allow the GPU Operator Daemonsets to run on tainted GPU nodes.

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

This component is intended to be used with additional configurations to set the number of replicas.

Please refer to [schedule-on-tainted-nodes](../schedule-on-tainted-nodes) and [schedule-on-tainted-nodes](../schedule-on-tainted-nodes) for complete implementations of the time slicing configuration.
