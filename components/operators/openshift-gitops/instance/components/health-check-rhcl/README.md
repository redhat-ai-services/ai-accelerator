# health-check-rhcl

## Purpose
This component is designed to enable custom health checks for Red Hat Connectivity Link objects:

* `Authorino`
* `Kuadrant`

## Usage

This component can be added to a base by adding the `components` section to your overlay `kustomization.yaml` file:

```
apiVersion: kustomize.config.k8s.io/v1beta1
kind: Kustomization

resources:
  - ../../base

components:
  - ../../components/health-check-rhcl
```
