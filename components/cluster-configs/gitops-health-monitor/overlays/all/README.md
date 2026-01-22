# GitOps Health Monitor

Automated deployment health monitoring and self-healing for baremetal GPU/RDMA deployments.

## Features

This component monitors ArgoCD applications during deployment and automatically fixes common issues:
- ✓ Stuck sync operations (clears operations stuck > 3 minutes)
- ✓ Failed PreSync hooks (retriggers sync)
- ✓ Stuck ArgoCD hook Jobs (removes finalizers)
- ✓ Stuck OLM operators (deletes and recreates CSVs)
- ✓ Broken subscriptions (recreates subscriptions referencing deleted InstallPlans)
- ✓ SR-IOV infrastructure issues (retries failed generator jobs)
- ✓ Pods stuck in Pending state (reports issues)

## Auto-Cleanup

**The health monitor automatically removes itself once all baremetal components are healthy.**

When all baremetal applications reach `Synced/Healthy` status, the monitor:
1. Detects deployment is complete
2. Deletes its own ArgoCD Application
3. Gets removed by ArgoCD cascade deletion

This typically happens 10-20 minutes after deployment starts.

## Configuration Options

### Option 1: Standard Deployment (Recommended - Default)

Use the `all` overlay for automatic cleanup:

```yaml
- name: gitops-health-monitor
  path: components/cluster-configs/gitops-health-monitor
  wave: "-2"
  overlay: "all"
  repoURL: "https://github.com/redhat-ai-services/ai-accelerator.git"
  targetRevision: "main"
```

**Behavior**: Monitor runs every 2 minutes, auto-removes when deployment is complete.

### Option 2: Persistent Monitoring (No Auto-Cleanup)

Use the `persistent` overlay for ongoing monitoring without auto-cleanup:

```yaml
- name: gitops-health-monitor
  path: components/cluster-configs/gitops-health-monitor
  wave: "-2"
  overlay: "persistent"  # Use persistent overlay
  repoURL: "https://github.com/redhat-ai-services/ai-accelerator.git"
  targetRevision: "main"
```

**Behavior**: Monitor runs indefinitely for continuous health monitoring.

### Option 3: Disabled (No Health Monitor)

Remove the `gitops-health-monitor` entry from your ApplicationSet:

```yaml
# In patch-baremetal-configs-repo.yaml or baremetal-configs-applicationset.yaml
# Delete this entire block:
- name: gitops-health-monitor
  path: components/cluster-configs/gitops-health-monitor
  wave: "-2"
  overlay: "all"
  repoURL: "..."
  targetRevision: "..."
```

**Behavior**: No health monitoring. Manual intervention required for deployment issues.

## Monitoring the Health Monitor

To see the health monitor in action:

```bash
# Watch the CronJob execution
oc get cronjob argocd-health-monitor -n openshift-gitops

# View recent job logs
oc logs -n openshift-gitops -l job-name --tail=100 | grep argocd-health-monitor

# Check deployment progress
oc get application -n openshift-gitops | grep baremetal
```

## When to Use Each Option

| Scenario | Recommended Option |
|----------|-------------------|
| Fresh baremetal deployment | **Option 1 (all)** - Auto-cleanup after deployment |
| Production cluster with occasional issues | **Option 2 (persistent)** - Continuous monitoring |
| Testing/development | **Option 1 (all)** - Clean deployments |
| CI/CD pipelines | **Option 1 (all)** - Automated cleanup |
| Minimal dependencies | **Option 3 (disabled)** - No health monitor |
