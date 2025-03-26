# patch-trustyai-configmap

## Purpose
This component is designed to patch trustyai-service-operator-config ConfigMap to allow online connections for LM-Eval model evaluation to be able to connect to huggingface.co

## Usage

This component can be added to a base by adding the `components` section to your overlay `kustomization.yaml` file:

```
apiVersion: kustomize.config.k8s.io/v1beta1
kind: Kustomization

resources:
  - ../../base

components:
  - ../../components/patch-trustyai-configmap
```


## Reference
- https://docs.redhat.com/en/documentation/red_hat_openshift_ai_cloud_service/1/html/monitoring_data_science_models/evaluating-large-language-models_monitor#setting-up-lmeval_monitor - "Enabling allowOnline mode" sub-section
