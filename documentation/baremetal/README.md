# Baremetal GPU + RDMA/RoCE Deployments

This directory contains documentation for deploying Red Hat OpenShift AI on baremetal clusters with NVIDIA GPUs and RDMA/RoCE networking.

## Overview

The baremetal deployment overlays add the following infrastructure components on top of the standard RHOAI deployment:

### Network Components
- **NVIDIA Network Operator** - MOFED drivers for RDMA/RoCE networking
- **SR-IOV Network Operator** - Network virtualization for high-performance NICs
- **RoCE Discovery** - Automatic detection of RDMA-capable NICs and SR-IOV policy generation

### Cluster Configuration
- **Node Preparation** - Automatic labeling and configuration of worker/master nodes
- **GitOps Health Monitor** - Self-healing monitor for stuck operators and resources (enabled by default with auto-cleanup)
- **Network Performance Tests** - Comprehensive RDMA, TCP, and NCCL benchmarking

## Prerequisites

Before deploying a baremetal overlay, ensure your cluster meets these requirements:

### Hardware Requirements
- **GPU**: NVIDIA GPUs (V100, A100, H100, H200, etc.)
- **Network**: Mellanox/NVIDIA ConnectX NICs with RoCE support (ConnectX-5, ConnectX-6, ConnectX-7)
- **Nodes**: Dedicated worker nodes (separate from control plane)

### Software Requirements
- **OpenShift**: Version 4.12 or higher
- **Cluster Access**: `cluster-admin` privileges
- **Tools**: `oc`, `kubectl`, `kustomize` (v5.0+)

### Network Configuration
- **RDMA/RoCE**: NICs configured for RoCE mode
- **SR-IOV**: VFs (Virtual Functions) available on NICs
- **Subnets**: IP addressing plan for SR-IOV networks

## Available Overlays

Three baremetal overlays are available, corresponding to RHOAI release channels:

| Overlay | RHOAI Channel | Support Duration | Use Case |
|---------|---------------|------------------|----------|
| `rhoai-stable-2.25-baremetal` | stable-2.25 | 7 months | Production deployments |
| `rhoai-fast-baremetal` | fast | Monthly releases | Latest features, experimental |
| `rhoai-eus-2.16-baremetal` | eus-2.16 | 18 months | Long-term support |

## Deployment

### Quick Start

```bash
# Clone the repository
git clone https://github.com/redhat-ai-services/ai-accelerator.git
cd ai-accelerator

# Run the bootstrap script
./bootstrap.sh

# Select a baremetal overlay when prompted:
#   11) rhoai-stable-2.25-baremetal
#   12) rhoai-fast-baremetal
#   13) rhoai-eus-2.16-baremetal
```

### Two-Step Deployment Process

The baremetal deployment follows a two-step process:

#### Step 1: Deploy Prerequisites

First, deploy the prerequisite components using the bootstrap script:

```bash
# Deploy GitOps operator and base configuration
./bootstrap.sh
```

This sets up the foundational GitOps infrastructure.

#### Step 2: Apply the Baremetal Overlay

Then, apply the specific baremetal overlay using kustomize:

```bash
# Apply the baremetal overlay
oc apply -k bootstrap/overlays/rhoai-stable-2.25-baremetal

# Wait for ArgoCD to sync
watch oc get applications.argoproj.io -n openshift-gitops

# Monitor baremetal components
oc get applications.argoproj.io -n openshift-gitops | grep baremetal
```

### Alternative: Direct Kustomization

You can also apply the overlay directly without using bootstrap.sh:

```bash
# Apply the bootstrap overlay directly
oc apply -k bootstrap/overlays/rhoai-stable-2.25-baremetal

# Verify applications were created
oc get applications.argoproj.io -n openshift-gitops
```

### Recent Improvements

#### SR-IOV Webhook Readiness (commits `50ecfb7` and `02f6f46`)

The SR-IOV resource generator now includes:
- Webhook readiness checks before applying policies
- Proper RBAC permissions for service and endpoint queries
- Retry logic for transient webhook errors
- Detection of ongoing node reconfigurations

These improvements prevent "no endpoints available" errors during initial deployment when the SR-IOV operator webhook is still initializing.

### Verification Steps

After deployment, verify all components are healthy:

```bash
# Check all applications are synced
oc get applications.argoproj.io -n openshift-gitops

# Verify SR-IOV policies were created
oc get sriovnetworknodepolicies -n openshift-sriov-network-operator

# Verify SR-IOV networks were created
oc get sriovnetworks -n openshift-sriov-network-operator

# Check node states (may show "InProgress" during initial VF configuration)
oc get sriovnetworknodestates -n openshift-sriov-network-operator

# Monitor resource generator job logs
oc logs -n openshift-sriov-network-operator -l job-name=sriov-resource-generator --tail=50
```

Expected output:
- All ArgoCD applications show "Synced" and "Healthy" status
- SR-IOV policies created for each detected RoCE NIC (e.g., `policy-ens3f0np0`)
- SR-IOV networks created for each policy (e.g., `ens3f0np0-network`)
- Resource generator job completes with "✓ All resources applied successfully!"

## Deployment Order (Sync Waves)

The baremetal components deploy in this order:

```
Wave -2: ArgoCD Health Monitor (self-healing)
Wave -1: Node Preparation (labeling/tainting)
Wave 0:  Standard RHOAI operators
Wave 1:  SR-IOV Network Operator
Wave 2:  NVIDIA Network Operator + RoCE Discovery
Wave 3:  MOFED Readiness Check
Wave 4:  GPU Operator + RoCE NIC Detection
Wave 5+: RHOAI components
Wave 9:  Network Performance Tests (optional)
```

## GitOps Health Monitor

The GitOps Health Monitor is **enabled by default** in all baremetal overlays. It provides automated self-healing during deployment.

### Features

- Monitors ArgoCD applications every 2 minutes
- Automatically fixes stuck sync operations, failed hooks, broken OLM subscriptions
- Tracks deployment progress (e.g., "5/8 applications healthy")
- **Auto-removes itself** when all baremetal components are Synced/Healthy
- Typically completes and self-removes after 10-20 minutes

### Configuration Options

#### Option 1: Auto-Cleanup (Default - Enabled)

This is the **current default configuration**. The health monitor:
- Deploys during bootstrap (sync wave -2)
- Monitors and fixes issues during deployment
- Automatically removes itself when deployment is complete

**No configuration changes needed** - this is already set up.

#### Option 2: Persistent Monitoring (No Auto-Cleanup)

For production clusters that need continuous monitoring, change the overlay to `persistent`:

```yaml
# Edit: components/argocd/apps/overlays/rhoai-stable-2.25-baremetal/baremetal-configs-applicationset.yaml
- name: gitops-health-monitor
  path: components/cluster-configs/gitops-health-monitor
  wave: "-2"
  overlay: "persistent"  # Changed from "all" to "persistent"
```

The monitor will run indefinitely without auto-cleanup.

#### Option 3: Disabled (No Health Monitor)

To disable the health monitor completely, remove it from the ApplicationSet:

```yaml
# Edit: components/argocd/apps/overlays/rhoai-stable-2.25-baremetal/baremetal-configs-applicationset.yaml
# Delete this entire block:
- name: gitops-health-monitor
  path: components/cluster-configs/gitops-health-monitor
  wave: "-2"
  overlay: "all"
  repoURL: "PLACEHOLDER"
  targetRevision: "PLACEHOLDER"
```

Also remove from the corresponding patch file:
```bash
# Edit: clusters/overlays/rhoai-stable-2.25-baremetal/patch-baremetal-configs-repo.yaml
# Delete the gitops-health-monitor entry
```

### Monitoring the Health Monitor

Watch the health monitor in action:

```bash
# Check if health monitor is running
oc get cronjob argocd-health-monitor -n openshift-gitops

# View deployment progress in logs
oc logs -n openshift-gitops -l job-name --tail=50 | grep -A 20 "Deployment progress"

# Watch for auto-cleanup message
oc logs -n openshift-gitops -l job-name --tail=100 | grep -A 10 "All baremetal components are healthy"
```

When deployment is complete, you'll see:
```
🎉 All baremetal components are healthy!
Auto-cleanup: Removing health monitor Application...
✓ Health monitor Application deleted successfully
```

### Detailed Documentation

For complete health monitor documentation, see:
- [GitOps Health Monitor README](../../components/cluster-configs/gitops-health-monitor/overlays/all/README.md)

## Verification

### Check Operator Status

```bash
# Check all operators are installed
oc get csv -A | grep -E "nvidia|sriov"

# Verify MOFED driver pods
oc get pods -n nvidia-network-operator-resources -l app=mofed-driver

# Verify SR-IOV operator
oc get pods -n openshift-sriov-network-operator
```

### Check Node Configuration

```bash
# Verify worker nodes are labeled
oc get nodes -l fab-rig-deployer=true

# Check GPU operands are disabled on masters
oc get nodes -l nvidia.com/gpu.deploy.operands=false

# Check MOFED driver status on nodes
oc get nodes -o json | jq '.items[] | {name: .metadata.name, mofed: .status.allocatable["nvidia.com/rdma_shared_device_a"]}'
```

### Check RoCE Discovery

```bash
# View discovered NICs
oc get configmap -n openshift-sriov-network-operator roce-nic-info -o yaml

# Check generated SR-IOV policies
oc get sriovnetworknodepolicy -n openshift-sriov-network-operator
```

### Run Network Performance Tests

```bash
# Check if network perf tests are deployed
oc get job -n default network-perf-test

# View test results
oc logs job/network-perf-test -n default | tail -100

# Access web report (if deployed)
oc get route -n default network-perf-report
```

## Architecture

### Component Relationships

```
┌─────────────────────────────────────────────────────────────┐
│                    ArgoCD (OpenShift GitOps)                 │
│  ┌──────────────────────────────────────────────────────┐   │
│  │           Baremetal ApplicationSets                   │   │
│  │  ┌────────────────────┬──────────────────────────┐   │   │
│  │  │ Baremetal Operators│  Baremetal Configs       │   │   │
│  │  │  • NVIDIA Network  │   • Node Preparation     │   │   │
│  │  │  • SR-IOV          │   • RoCE Discovery       │   │   │
│  │  └────────────────────┴──────────────────────────┘   │   │
│  └──────────────────────────────────────────────────────┘   │
└─────────────────────────────────────────────────────────────┘
                            │
            ┌───────────────┴────────────────┐
            │                                │
    ┌───────▼────────┐            ┌─────────▼──────────┐
    │  Worker Nodes  │            │  Master Nodes      │
    │  • GPU enabled │            │  • GPU disabled    │
    │  • MOFED       │            │  • MOFED disabled  │
    │  • SR-IOV VFs  │            │  • No workloads    │
    └────────────────┘            └────────────────────┘
```

### Network Flow

```
Pod with GPU Workload
    │
    ├─► eth0 (default network)
    │
    ├─► net1 (SR-IOV VF #1 - RoCE)
    │     └─► RDMA device (GPUDirect)
    │
    └─► net2 (SR-IOV VF #2 - RoCE)
          └─► RDMA device (GPUDirect)
```

## Troubleshooting

See [troubleshooting.md](troubleshooting.md) for common issues and solutions.

## Advanced Topics

- [GPU and RDMA Setup](gpu-rdma-setup.md) - Detailed hardware configuration
- [Network Performance Testing](network-performance.md) - Running and interpreting benchmarks
- [RoCE Discovery](roce-discovery.md) - Understanding automatic NIC detection

## Differences from AWS GPU Overlays

| Feature | AWS GPU Overlays | Baremetal Overlays |
|---------|------------------|---------------------|
| **Network** | ENA (Elastic Network Adapter) | RDMA/RoCE with SR-IOV |
| **GPU Drivers** | AWS-optimized images | Universal pre-built drivers |
| **Node Prep** | AWS-specific taints | Master/worker separation |
| **Storage** | EBS volumes | Local or network storage |
| **Networking** | VPC networking | Physical network fabric |

## Support

For issues specific to baremetal deployments:
1. Check [troubleshooting.md](troubleshooting.md)
2. Review ArgoCD application status: `oc get applications -n openshift-gitops`
3. Check health monitor logs: `oc logs -n openshift-gitops -l job-name=argocd-health-monitor`
4. Open an issue at https://github.com/redhat-ai-services/ai-accelerator/issues

## Contributing

See [CONTRIBUTING.md](../../CONTRIBUTING.md) for guidelines on contributing baremetal improvements.
