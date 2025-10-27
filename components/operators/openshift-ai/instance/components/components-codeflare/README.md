# components-distributed-compute

## Purpose
This component is designed help configure the distributed compute specific components including the following items:

CodeFlare

Warning: CodeFlare has been depreciated as of 2.24.

## Usage

This component can be added to a base by adding the `components` section to your overlay `kustomization.yaml` file:

```
apiVersion: kustomize.config.k8s.io/v1beta1
kind: Kustomization

resources:
  - ../../base

components:
  - ../../components/components-distributed-compute
```
