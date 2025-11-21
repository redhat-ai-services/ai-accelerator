# components-kueue

## Purpose
This component is designed help configure the distributed compute specific components including the following items:

Kueue

Warning: The OpenShift AI distribution of Kueue has been depreciated as of 2.24.  Use the Red Hat Build of Kueue operator available through OperatorHub instead.

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
