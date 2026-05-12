#!/usr/bin/env bash

set -e

echo "================================================"
echo "Red Hat OpenShift AI Cleanup"
echo "================================================"
echo ""
echo "Following: docs.redhat.com/en/documentation/red_hat_openshift_ai_self-managed"
echo ""

# Step 0: Delete user workload CRs across all namespaces before removing the DSC.
# Deleting CRs first prevents finalizer deadlocks during operator cleanup.
echo "Step 0: Deleting user workload CRs..."

# Data Science Pipelines
oc delete datasciencepipelinesapplications.datasciencepipelinesapplications.opendatahub.io \
  -A --all --ignore-not-found 2>/dev/null || true
oc delete datasciencepipelines.components.platform.opendatahub.io \
  -A --all --ignore-not-found 2>/dev/null || true

# Argo Workflows
oc delete clusterworkflowtemplates.argoproj.io --all --ignore-not-found 2>/dev/null || true
oc delete cronworkflows.argoproj.io -A --all --ignore-not-found 2>/dev/null || true
oc delete workflowartifactgctasks.argoproj.io -A --all --ignore-not-found 2>/dev/null || true
oc delete workfloweventbindings.argoproj.io -A --all --ignore-not-found 2>/dev/null || true
oc delete workflows.argoproj.io -A --all --ignore-not-found 2>/dev/null || true
oc delete workflowtaskresults.argoproj.io -A --all --ignore-not-found 2>/dev/null || true
oc delete workflowtasksets.argoproj.io -A --all --ignore-not-found 2>/dev/null || true
oc delete workflowtemplates.argoproj.io -A --all --ignore-not-found 2>/dev/null || true

# KServe
oc delete clusterstoragecontainers.serving.kserve.io --all --ignore-not-found 2>/dev/null || true
oc delete inferencegraphs.serving.kserve.io -A --all --ignore-not-found 2>/dev/null || true
oc delete inferenceservices.serving.kserve.io -A --all --ignore-not-found 2>/dev/null || true
oc delete llminferenceserviceconfigs.serving.kserve.io -A --all --ignore-not-found 2>/dev/null || true
oc delete llminferenceservices.serving.kserve.io -A --all --ignore-not-found 2>/dev/null || true
oc delete predictors.serving.kserve.io -A --all --ignore-not-found 2>/dev/null || true
oc delete servingruntimes.serving.kserve.io -A --all --ignore-not-found 2>/dev/null || true
oc delete trainedmodels.serving.kserve.io -A --all --ignore-not-found 2>/dev/null || true

# Inference (networking)
oc delete inferencemodels.inference.networking.x-k8s.io -A --all --ignore-not-found 2>/dev/null || true
oc delete inferencepools.inference.networking.x-k8s.io -A --all --ignore-not-found 2>/dev/null || true

# Kueue
oc delete admissionchecks.kueue.x-k8s.io --all --ignore-not-found 2>/dev/null || true
oc delete clusterqueues.kueue.x-k8s.io --all --ignore-not-found 2>/dev/null || true
oc delete cohorts.kueue.x-k8s.io --all --ignore-not-found 2>/dev/null || true
oc delete localqueues.kueue.x-k8s.io -A --all --ignore-not-found 2>/dev/null || true
oc delete multikueueclusters.kueue.x-k8s.io --all --ignore-not-found 2>/dev/null || true
oc delete multikueueconfigs.kueue.x-k8s.io --all --ignore-not-found 2>/dev/null || true
oc delete provisioningrequestconfigs.kueue.x-k8s.io --all --ignore-not-found 2>/dev/null || true
oc delete resourceflavors.kueue.x-k8s.io --all --ignore-not-found 2>/dev/null || true
oc delete topologies.kueue.x-k8s.io --all --ignore-not-found 2>/dev/null || true
oc delete workloadpriorityclasses.kueue.x-k8s.io --all --ignore-not-found 2>/dev/null || true
oc delete workloads.kueue.x-k8s.io -A --all --ignore-not-found 2>/dev/null || true

# Workbenches
oc delete notebooks.kubeflow.org -A --all --ignore-not-found 2>/dev/null || true

# Kubeflow Training Operator
oc delete jaxjobs.kubeflow.org -A --all --ignore-not-found 2>/dev/null || true
oc delete mpijobs.kubeflow.org -A --all --ignore-not-found 2>/dev/null || true
oc delete mxjobs.kubeflow.org -A --all --ignore-not-found 2>/dev/null || true
oc delete paddlejobs.kubeflow.org -A --all --ignore-not-found 2>/dev/null || true
oc delete pipelines.pipelines.kubeflow.org -A --all --ignore-not-found 2>/dev/null || true
oc delete pipelineversions.pipelines.kubeflow.org -A --all --ignore-not-found 2>/dev/null || true
oc delete pytorchjobs.kubeflow.org -A --all --ignore-not-found 2>/dev/null || true
oc delete scheduledworkflows.kubeflow.org -A --all --ignore-not-found 2>/dev/null || true
oc delete tfjobs.kubeflow.org -A --all --ignore-not-found 2>/dev/null || true
oc delete viewers.kubeflow.org -A --all --ignore-not-found 2>/dev/null || true
oc delete xgboostjobs.kubeflow.org -A --all --ignore-not-found 2>/dev/null || true

# TrustyAI
oc delete guardrailsorchestrators.trustyai.opendatahub.io -A --all --ignore-not-found 2>/dev/null || true
oc delete lmevaljobs.trustyai.opendatahub.io -A --all --ignore-not-found 2>/dev/null || true
oc delete nemoguardrails.trustyai.opendatahub.io -A --all --ignore-not-found 2>/dev/null || true
oc delete trustyaiservices.trustyai.opendatahub.io -A --all --ignore-not-found 2>/dev/null || true

# Ray
oc delete rayclusters.ray.io -A --all --ignore-not-found 2>/dev/null || true
oc delete rayjobs.ray.io -A --all --ignore-not-found 2>/dev/null || true
oc delete rayservices.ray.io -A --all --ignore-not-found 2>/dev/null || true

# CodeFlare / AppWrappers
oc delete appwrappers.workload.codeflare.dev -A --all --ignore-not-found 2>/dev/null || true

# Feast
oc delete featurestores.feast.dev -A --all --ignore-not-found 2>/dev/null || true

# LlamaStack
oc delete llamastackdistributions.llamastack.io -A --all --ignore-not-found 2>/dev/null || true

# Model Registry
oc delete modelregistries.modelregistry.opendatahub.io -A --all --ignore-not-found 2>/dev/null || true

# RHOAI / ODH platform CRs
oc delete accounts.nim.opendatahub.io -A --all --ignore-not-found 2>/dev/null || true
oc delete applications.app.k8s.io -A --all --ignore-not-found 2>/dev/null || true
oc delete auths.services.platform.opendatahub.io -A --all --ignore-not-found 2>/dev/null || true
oc delete dashboards.components.platform.opendatahub.io -A --all --ignore-not-found 2>/dev/null || true
oc delete feastoperators.components.platform.opendatahub.io -A --all --ignore-not-found 2>/dev/null || true
oc delete kserves.components.platform.opendatahub.io -A --all --ignore-not-found 2>/dev/null || true
oc delete kueues.components.platform.opendatahub.io -A --all --ignore-not-found 2>/dev/null || true
oc delete llamastackoperators.components.platform.opendatahub.io -A --all --ignore-not-found 2>/dev/null || true
oc delete modelcontrollers.components.platform.opendatahub.io -A --all --ignore-not-found 2>/dev/null || true
oc delete modelmeshservings.components.platform.opendatahub.io -A --all --ignore-not-found 2>/dev/null || true
oc delete modelregistries.components.platform.opendatahub.io -A --all --ignore-not-found 2>/dev/null || true
oc delete monitorings.services.platform.opendatahub.io -A --all --ignore-not-found 2>/dev/null || true
oc delete rays.components.platform.opendatahub.io -A --all --ignore-not-found 2>/dev/null || true
oc delete servicemeshes.services.platform.opendatahub.io -A --all --ignore-not-found 2>/dev/null || true
oc delete trainingoperators.components.platform.opendatahub.io -A --all --ignore-not-found 2>/dev/null || true
oc delete trustyais.components.platform.opendatahub.io -A --all --ignore-not-found 2>/dev/null || true
oc delete workbenches.components.platform.opendatahub.io -A --all --ignore-not-found 2>/dev/null || true

echo "  Done"
echo ""

# Step 1: Delete DataScienceCluster and DSCInitialization
echo "Step 1: Deleting DataScienceCluster and DSCInitialization..."
oc delete datascienceclusters.datasciencecluster.opendatahub.io --all --ignore-not-found 2>/dev/null || true
oc delete dscinitializations.dscinitialization.opendatahub.io --all --ignore-not-found 2>/dev/null || true
oc delete featuretrackers.features.opendatahub.io --all --ignore-not-found 2>/dev/null || true
echo "  Done"
echo ""

# Step 2: Delete OLM resources
echo "Step 2: Deleting Subscription, CSV, OperatorGroup, InstallPlan..."
oc delete subscription --all -n redhat-ods-operator --ignore-not-found
oc delete clusterserviceversion --all -n redhat-ods-operator --ignore-not-found
oc delete operatorgroup --all -n redhat-ods-operator --ignore-not-found
oc delete installplan --all -n redhat-ods-operator --ignore-not-found
echo "  Done"
echo ""

# Step 3: Delete webhooks
echo "Step 3: Deleting RHOAI webhooks..."
oc get validatingwebhookconfiguration -o name 2>/dev/null \
  | grep -E "opendatahub|kserve|rhoai" \
  | xargs -r oc delete --ignore-not-found 2>/dev/null || true
oc get mutatingwebhookconfiguration -o name 2>/dev/null \
  | grep -E "opendatahub|kserve|rhoai" \
  | xargs -r oc delete --ignore-not-found 2>/dev/null || true
echo "  Done"
echo ""

# Step 4: Delete RHOAI namespaces
echo "Step 4: Deleting RHOAI namespaces..."
oc delete namespace redhat-ods-applications --ignore-not-found 2>/dev/null || true
oc delete namespace redhat-ods-monitoring --ignore-not-found 2>/dev/null || true
oc delete namespace redhat-ods-operator --ignore-not-found 2>/dev/null || true
oc delete namespace rhods-notebooks --ignore-not-found 2>/dev/null || true
echo "  Done"
echo ""

# Step 5: Delete RHOAI CRDs
echo "Step 5: Deleting RHOAI CRDs..."

# Data Science Pipelines
oc delete crd \
  datasciencepipelinesapplications.datasciencepipelinesapplications.opendatahub.io \
  datasciencepipelines.components.platform.opendatahub.io \
  --ignore-not-found 2>/dev/null || true

# Argo Workflows
oc delete crd \
  clusterworkflowtemplates.argoproj.io \
  cronworkflows.argoproj.io \
  workflowartifactgctasks.argoproj.io \
  workfloweventbindings.argoproj.io \
  workflows.argoproj.io \
  workflowtaskresults.argoproj.io \
  workflowtasksets.argoproj.io \
  workflowtemplates.argoproj.io \
  --ignore-not-found 2>/dev/null || true

# KServe
oc delete crd \
  clusterstoragecontainers.serving.kserve.io \
  inferencegraphs.serving.kserve.io \
  inferenceservices.serving.kserve.io \
  llminferenceserviceconfigs.serving.kserve.io \
  llminferenceservices.serving.kserve.io \
  predictors.serving.kserve.io \
  servingruntimes.serving.kserve.io \
  trainedmodels.serving.kserve.io \
  --ignore-not-found 2>/dev/null || true

# Inference (networking)
oc delete crd \
  inferencemodels.inference.networking.x-k8s.io \
  inferencepools.inference.networking.x-k8s.io \
  --ignore-not-found 2>/dev/null || true

# Kueue
oc delete crd \
  admissionchecks.kueue.x-k8s.io \
  clusterqueues.kueue.x-k8s.io \
  cohorts.kueue.x-k8s.io \
  localqueues.kueue.x-k8s.io \
  multikueueclusters.kueue.x-k8s.io \
  multikueueconfigs.kueue.x-k8s.io \
  provisioningrequestconfigs.kueue.x-k8s.io \
  resourceflavors.kueue.x-k8s.io \
  topologies.kueue.x-k8s.io \
  workloadpriorityclasses.kueue.x-k8s.io \
  workloads.kueue.x-k8s.io \
  --ignore-not-found 2>/dev/null || true

# Workbenches / Kubeflow
oc delete crd \
  notebooks.kubeflow.org \
  viewers.kubeflow.org \
  --ignore-not-found 2>/dev/null || true

# Kubeflow Training Operator
oc delete crd \
  jaxjobs.kubeflow.org \
  mpijobs.kubeflow.org \
  mxjobs.kubeflow.org \
  paddlejobs.kubeflow.org \
  pipelines.pipelines.kubeflow.org \
  pipelineversions.pipelines.kubeflow.org \
  pytorchjobs.kubeflow.org \
  scheduledworkflows.kubeflow.org \
  tfjobs.kubeflow.org \
  xgboostjobs.kubeflow.org \
  --ignore-not-found 2>/dev/null || true

# TrustyAI
oc delete crd \
  guardrailsorchestrators.trustyai.opendatahub.io \
  lmevaljobs.trustyai.opendatahub.io \
  nemoguardrails.trustyai.opendatahub.io \
  trustyaiservices.trustyai.opendatahub.io \
  --ignore-not-found 2>/dev/null || true

# Ray
oc delete crd \
  rayclusters.ray.io \
  rayjobs.ray.io \
  rayservices.ray.io \
  --ignore-not-found 2>/dev/null || true

# CodeFlare
oc delete crd appwrappers.workload.codeflare.dev --ignore-not-found 2>/dev/null || true

# Feast
oc delete crd \
  feastoperators.components.platform.opendatahub.io \
  featurestores.feast.dev \
  --ignore-not-found 2>/dev/null || true

# LlamaStack
oc delete crd llamastackdistributions.llamastack.io --ignore-not-found 2>/dev/null || true

# RHOAI / ODH platform components
oc delete crd \
  accounts.nim.opendatahub.io \
  applications.app.k8s.io \
  auths.services.platform.opendatahub.io \
  codeflares.components.platform.opendatahub.io \
  dashboards.components.platform.opendatahub.io \
  kserves.components.platform.opendatahub.io \
  kueues.components.platform.opendatahub.io \
  llamastackoperators.components.platform.opendatahub.io \
  mlflowoperators.components.platform.opendatahub.io \
  modelcontrollers.components.platform.opendatahub.io \
  modelmeshservings.components.platform.opendatahub.io \
  modelregistries.components.platform.opendatahub.io \
  modelregistries.modelregistry.opendatahub.io \
  monitorings.services.platform.opendatahub.io \
  rays.components.platform.opendatahub.io \
  servicemeshes.services.platform.opendatahub.io \
  trainingoperators.components.platform.opendatahub.io \
  trainers.components.platform.opendatahub.io \
  trustyais.components.platform.opendatahub.io \
  workbenches.components.platform.opendatahub.io \
  --ignore-not-found 2>/dev/null || true

# RHOAI core
oc delete crd \
  acceleratorprofiles.dashboard.opendatahub.io \
  datascienceclusters.datasciencecluster.opendatahub.io \
  dscinitializations.dscinitialization.opendatahub.io \
  featuretrackers.features.opendatahub.io \
  gatewayconfigs.services.platform.opendatahub.io \
  hardwareprofiles.dashboard.opendatahub.io \
  hardwareprofiles.infrastructure.opendatahub.io \
  modelsasservices.components.platform.opendatahub.io \
  odhapplications.dashboard.opendatahub.io \
  odhdashboardconfigs.opendatahub.io \
  odhdocuments.dashboard.opendatahub.io \
  odhquickstarts.console.openshift.io \
  --ignore-not-found 2>/dev/null || true

echo "  Done"
echo ""

echo "================================================"
echo "RHOAI cleanup completed"
echo "================================================"
