# Baremetal Deployment Troubleshooting

Common issues and solutions for baremetal GPU + RDMA deployments.

## Operator Issues

### NVIDIA Network Operator Stuck Installing

**Symptom**: `nvidia-network-operator` CSV stays in `Installing` state

**Diagnosis**:
```bash
oc get csv -n nvidia-network-operator-resources
oc describe csv nvidia-network-operator -n nvidia-network-operator-resources
```

**Solutions**:
1. Check if MOFED driver pods are failing:
   ```bash
   oc get pods -n nvidia-network-operator-resources -l app=mofed-driver
   oc logs -n nvidia-network-operator-resources -l app=mofed-driver --tail=50
   ```

2. Verify kernel compatibility:
   ```bash
   oc debug node/<worker-node>
   chroot /host
   uname -r  # Check kernel version
   ```

3. Check for conflicting MOFED installations:
   ```bash
   oc debug node/<worker-node>
   chroot /host
   rpm -qa | grep mlnx
   ```

### SR-IOV Operator Not Creating VFs

**Symptom**: `SriovNetworkNodePolicy` created but no VFs appear

**Diagnosis**:
```bash
# Check SR-IOV node state
oc get sriovnetworknodestate -n openshift-sriov-network-operator

# Check operator logs
oc logs -n openshift-sriov-network-operator deployment/sriov-network-operator
```

**Solutions**:
1. Verify NICs support SR-IOV:
   ```bash
   oc debug node/<worker-node>
   chroot /host
   lspci | grep Mellanox
   cat /sys/class/net/<nic>/device/sriov_totalvfs
   ```

2. Check if policy matches NIC:
   ```bash
   oc get sriovnetworknodepolicy -n openshift-sriov-network-operator -o yaml
   # Verify nicSelector matches your NIC's vendor/device IDs
   ```

3. Manually trigger node drain (if disabled):
   ```bash
   oc patch sriovnetworknodepolicy <policy-name> -n openshift-sriov-network-operator \
     --type=merge -p '{"spec":{"needDrain":true}}'
   ```

## RoCE Discovery Issues

### No RoCE NICs Detected

**Symptom**: RoCE discovery daemonset runs but finds no NICs

**Diagnosis**:
```bash
# Check discovery daemonset logs
oc logs -n openshift-sriov-network-operator daemonset/roce-nic-discovery --tail=100

# Check NIC info ConfigMap
oc get configmap -n openshift-sriov-network-operator roce-nic-info -o yaml
```

**Solutions**:
1. Verify NICs have IP addresses:
   ```bash
   oc debug node/<worker-node>
   chroot /host
   ip addr show  # Check net1, net2, etc.
   ```

2. Check RoCE capability:
   ```bash
   oc debug node/<worker-node>
   chroot /host
   ibstat  # or: ibv_devinfo
   ```

3. Verify ethtool shows RoCE info:
   ```bash
   oc debug node/<worker-node>
   chroot /host
   ethtool -i net1
   ```

### SR-IOV Policies Not Generated

**Symptom**: RoCE NICs detected but no `SriovNetworkNodePolicy` created

**Diagnosis**:
```bash
# Check generator job logs
oc logs -n openshift-sriov-network-operator job/sriov-policy-generator --tail=100
```

**Solutions**:
1. Verify generator job RBAC:
   ```bash
   oc get role,rolebinding -n openshift-sriov-network-operator | grep generator
   ```

2. Check for existing conflicting policies:
   ```bash
   oc get sriovnetworknodepolicy -n openshift-sriov-network-operator
   # Look for policies with same NIC selector
   ```

3. Manually trigger regeneration:
   ```bash
   oc delete job -n openshift-sriov-network-operator sriov-policy-generator
   # ArgoCD will recreate it
   ```

## Node Issues

### Worker Nodes Not Labeled

**Symptom**: `oc get nodes -l fab-rig-deployer=true` returns no nodes

**Diagnosis**:
```bash
# Check node prep job
oc get job -n default prepare-nodes-for-fab-rig
oc logs -n default job/prepare-nodes-for-fab-rig
```

**Solutions**:
1. Manually label nodes:
   ```bash
   oc label node <worker-node> fab-rig-deployer=true
   ```

2. Re-run node prep job:
   ```bash
   oc delete job -n default prepare-nodes-for-fab-rig
   # ArgoCD will recreate it (PreSync hook)
   ```

### GPU Pods Scheduling on Master Nodes

**Symptom**: GPU workloads running on master nodes (not desired)

**Diagnosis**:
```bash
# Check master node labels
oc get nodes -l node-role.kubernetes.io/master -o json | \
  jq '.items[] | {name: .metadata.name, gpu_operands: .metadata.labels["nvidia.com/gpu.deploy.operands"]}'
```

**Solutions**:
1. Verify GPU operands disabled on masters:
   ```bash
   oc label node <master-node> nvidia.com/gpu.deploy.operands=false --overwrite
   ```

2. Add node affinity to your workloads:
   ```yaml
   affinity:
     nodeAffinity:
       requiredDuringSchedulingIgnoredDuringExecution:
         nodeSelectorTerms:
         - matchExpressions:
           - key: node-role.kubernetes.io/worker
             operator: Exists
           - key: node-role.kubernetes.io/master
             operator: DoesNotExist
   ```

## Network Performance Issues

### Poor RDMA Bandwidth

**Symptom**: Network perf tests show <50% of expected bandwidth

**Diagnosis**:
```bash
# Check test results
oc logs -n default job/network-perf-test | grep -A5 "RoCE+CUDA"
```

**Solutions**:
1. Verify GPUDirect is enabled:
   ```bash
   oc debug node/<worker-node>
   chroot /host
   cat /proc/driver/nvidia/gpus/*/information | grep -i direct
   ```

2. Check NIC link speed:
   ```bash
   oc debug node/<worker-node>
   chroot /host
   ethtool net1 | grep Speed
   ```

3. Verify RoCE flow control:
   ```bash
   oc debug node/<worker-node>
   chroot /host
   mlnx_qos -i net1
   ```

4. Check for packet drops:
   ```bash
   oc debug node/<worker-node>
   chroot /host
   ip -s link show net1
   ```

### NCCL Tests Failing

**Symptom**: NCCL all-reduce tests fail or timeout

**Diagnosis**:
```bash
# Check NCCL test logs
oc logs -n default job/network-perf-test | grep -A10 "NCCL"
```

**Solutions**:
1. Set NCCL debug level:
   ```bash
   # Add to test pod env:
   NCCL_DEBUG=INFO
   NCCL_DEBUG_SUBSYS=ALL
   ```

2. Force NCCL to use specific interface:
   ```bash
   NCCL_SOCKET_IFNAME=net1
   ```

3. Verify NCCL can detect GPUDirect:
   ```bash
   NCCL_NET_GDR_LEVEL=5  # Enable GPUDirect RDMA
   ```

## ArgoCD Issues

### Applications Stuck in Progressing

**Symptom**: ArgoCD applications show `Progressing` for >10 minutes

**Diagnosis**:
```bash
# Check application status
oc get application -n openshift-gitops baremetal-<component> -o yaml

# Check health monitor
oc logs -n openshift-gitops -l job-name=argocd-health-monitor --tail=50
```

**Solutions**:
1. Manually sync application:
   ```bash
   argocd app sync baremetal-<component>
   # or via oc:
   oc patch application baremetal-<component> -n openshift-gitops \
     --type=merge -p '{"operation":{"initiatedBy":{"automated":true}}}'
   ```

2. Check for stuck operations:
   ```bash
   oc get application -n openshift-gitops baremetal-<component> -o json | \
     jq '.status.operationState'
   ```

3. Delete stuck operation (health monitor does this automatically):
   ```bash
   oc patch application baremetal-<component> -n openshift-gitops \
     --type=json -p='[{"op":"remove","path":"/status/operationState"}]'
   ```

### Health Monitor Not Running

**Symptom**: No health monitor CronJob executions

**Diagnosis**:
```bash
# Check CronJob status
oc get cronjob -n openshift-gitops argocd-health-monitor

# Check recent jobs
oc get jobs -n openshift-gitops | grep argocd-health-monitor
```

**Solutions**:
1. Manually trigger health monitor:
   ```bash
   oc create job -n openshift-gitops \
     manual-health-check --from=cronjob/argocd-health-monitor
   ```

2. Check CronJob schedule:
   ```bash
   oc get cronjob -n openshift-gitops argocd-health-monitor -o yaml | grep schedule
   # Should be: "*/2 * * * *" (every 2 minutes)
   ```

## Getting Help

If issues persist:

1. **Collect diagnostics**:
   ```bash
   oc adm must-gather
   ```

2. **Export ArgoCD application status**:
   ```bash
   oc get applications -n openshift-gitops -o yaml > argocd-apps.yaml
   ```

3. **Gather operator logs**:
   ```bash
   oc logs -n nvidia-network-operator-resources deployment/nvidia-network-operator-controller-manager > nvidia-net-operator.log
   oc logs -n openshift-sriov-network-operator deployment/sriov-network-operator > sriov-operator.log
   ```

4. **Open an issue**: https://github.com/redhat-ai-services/ai-accelerator/issues
   - Include OpenShift version
   - Include hardware details (GPU model, NIC model)
   - Attach logs and diagnostics
