# wait-for-servicemesh

## Purpose

This component is designed prevent OpenShift AI before the ServiceMesh and ConnectivityLink resources have been successfully installed that are required for KServe. 

Additionally, this prevents the RHOAI3's DSCInitialization object from taking ownership of the Service Mesh 3 subscription and setting the installPlanApproval param to `Manual`, thus preventing any other operators in the namespace from using `installPlanApproval: Automatic` and syncing via ArgoCD.

## Usage

This component can be added to a base by adding the `components` section to your overlay `kustomization.yaml` file:

```
apiVersion: kustomize.config.k8s.io/v1beta1
kind: Kustomization

resources:
  - ../../base

components:
  - ../../components/wait-for-prereqs
```
