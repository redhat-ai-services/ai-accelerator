# rhoai-auth

## Purpose
This component replaces the `rhoai-dashboard-access` component and introduces a new auth object released in RHOAI 2.17.

## Usage

This component can be added to a base by adding the `components` section to your overlay `kustomization.yaml` file:

```
apiVersion: kustomize.config.k8s.io/v1beta1
kind: Kustomization

resources:
  - ../../base

components:
  - ../../components/rhoai-auth
```

You can customize the access by updating the [auth.yaml](./auth.yaml) file.
