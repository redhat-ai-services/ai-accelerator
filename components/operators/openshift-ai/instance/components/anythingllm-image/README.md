# anythingllm-image

## Purpose
This component gets an image stream with AnythingLLM to be used in a custom workbench.

For more information see the sample use here: [Using AnythingLLM as Custom Workbench](https://ai-on-openshift.io/odh-rhoai/custom-workbench-anythingllm/)

## Usage

This component can be added to a base by adding the `components` section to your overlay `kustomization.yaml` file:

```
apiVersion: kustomize.config.k8s.io/v1beta1
kind: Kustomization

resources:
  - ../../base

components:
  - ../../components/custom-anythingllm.yaml
```

