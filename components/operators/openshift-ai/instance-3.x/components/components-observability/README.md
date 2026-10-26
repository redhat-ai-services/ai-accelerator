# components-observability

## Purpose

This component configures observability for the RHOAI instance by patching the `DSCInitialization` resource. Monitoring is enabled and managed in the `redhat-ods-monitoring` namespace with the following storage configuration:

- Metrics storage of `50Gi` with a `90d` retention period
- Trace storage backed by a persistent volume with a `2160h` retention period

It also enables the Observability Dashboard section within the OpenShift AI Dashboard via the `OdhDashboardConfig` resource.

## Usage

This component can be added to a base by adding the `components` section to your overlay `kustomization.yaml` file:

```yaml
apiVersion: kustomize.config.k8s.io/v1beta1
kind: Kustomization

resources:
  - ../../base

components:
  - ../../components/components-observability
```
