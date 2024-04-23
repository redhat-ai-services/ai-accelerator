# NVIDIA GPU Operator Components

The included components are intended to be common patching patterns used on top of the default OpenShift Gitops instance to configure additional features of ArgoCD.  Components are composable patches that can be added at the overlays layer on top of a base.

This repo currently contains the following components:

* [console-plugin](console-plugin)
* [monitoring-dashboard](monitoring-dashboard)

## Usage

Components can be added to a base by adding the `components` section to your overlay `kustomization.yaml` file:

```
apiVersion: kustomize.config.k8s.io/v1beta1
kind: Kustomization

resources:
  - ../../base

components:
  - ../../components/console-plugin
  - ../../components/monitoring-dashboard
```
