# cleanup-on-delete

Runs the [official Red Hat RHOAI uninstall procedure](https://docs.redhat.com/en/documentation/red_hat_openshift_ai_self-managed) automatically as an ArgoCD `PreDelete` hook when the RHOAI Application is deleted.

Without this component, ArgoCD deletes RHOAI manifests in an arbitrary order, which leaves namespaces stuck in `Terminating` and webhooks that block future reinstalls.

## What it does

Executes a 5-step cleanup Job before ArgoCD removes any resources:

1. Delete all user workload CRs across all namespaces (InferenceServices, Notebooks, RayJobs, etc.) — prevents finalizer deadlocks
2. Delete the `DataScienceCluster` and `DSCInitialization` CRs
3. Delete OLM resources: `Subscription`, `ClusterServiceVersion`, `OperatorGroup`, `InstallPlan`
4. Delete RHOAI `ValidatingWebhookConfiguration` and `MutatingWebhookConfiguration` resources
5. Delete RHOAI namespaces and CRDs (explicit list per Red Hat documentation)

## How to enable

Add this component to your instance overlay's `components:` list:

```yaml
# components/operators/openshift-ai/instance-2.x/overlays/stable-2.25/kustomization.yaml
components:
  - ../../components/cleanup-on-delete
  - ../../components/components-kserve
  # ... other components
```

## Resources created

All resources are ArgoCD `PreDelete` hooks and are automatically cleaned up after the Job completes:

- `ConfigMap/rhoai-cleanup-script` in `openshift-gitops` — mounts the cleanup script
- `ServiceAccount/rhoai-cleanup` in `openshift-gitops`
- `ClusterRole/rhoai-cleanup`
- `ClusterRoleBinding/rhoai-cleanup`
- `Job/delete-rhoai-resources` in `openshift-gitops`

## Notes

- The cleanup script is maintained in `delete-rhoai-resources.sh` and mounted into the Job via a ConfigMap
- `backoffLimit: 0` — the Job does not retry
- The Job runs in `openshift-gitops` (not `redhat-ods-operator`) to avoid being killed when RHOAI namespaces are deleted
- The Job exits with code `0` even when resources are not found, so ArgoCD always proceeds with Application deletion
