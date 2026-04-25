# components-kserve

## Purpose

This component enables KServe in the DataScienceCluster for model serving. This configuration uses `rawDeploymentServiceConfig: Headed` which deploys models as standard Kubernetes Deployments with a headed service configuration.


## Usage

This component can be added to a base by adding the `components` section to your overlay `kustomization.yaml` file:

```yaml
apiVersion: kustomize.config.k8s.io/v1beta1
kind: Kustomization

resources:
  - ../../base

components:
  - ../../components/components-kserve
```
