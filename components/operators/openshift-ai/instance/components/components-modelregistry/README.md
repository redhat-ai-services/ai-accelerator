# components-modelregistry

## Purpose
This component is designed help index and manage models, versions, and artifacts metadata

## Usage

This component can be added to a base by adding the `components` section to your overlay `kustomization.yaml` file:

```
apiVersion: kustomize.config.k8s.io/v1beta1
kind: Kustomization

resources:
  - ../../base

components:
  - ../../components/components-modelregistry
```


## Enabling Model Registry to your cluster:
If you'd like to use the model-registry, 
add authorinio operator to `components > argocd > apps > overlays > rhoai-<version> >patch-operators-list.yaml`:

```
      - cluster: local
        url: https://kubernetes.default.svc
        values:
          name: authorino-operator
          path: components/operators/authorino-operator/operator/overlays/managed-services
```

and add model-registry components to `components > operators > openshift-ai > instance > overlays > <version> > kustomization.yaml`

`  - ../../components/components-modelregistry` 


Having an issue with namespace override, works if you comment/remove `namespace: redhat-ods-applications` from 
 `components > operators > openshift-ai > instance > overlays > <version > > kustomization.yaml` 