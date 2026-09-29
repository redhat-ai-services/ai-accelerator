```
# Data Science Pipelines
oc delete datasciencepipelinesapplications.datasciencepipelinesapplications.opendatahub.io -A --all --ignore-not-found
oc delete datasciencepipelines.components.platform.opendatahub.io -A --all --ignore-not-found

# Argo Workflows
oc delete clusterworkflowtemplates.argoproj.io -A --all --ignore-not-found
oc delete cronworkflows.argoproj.io -A --all --ignore-not-found
oc delete workflowartifactgctasks.argoproj.io -A --all --ignore-not-found
oc delete workfloweventbindings.argoproj.io -A --all --ignore-not-found
oc delete workflows.argoproj.io -A --all --ignore-not-found
oc delete workflowtaskresults.argoproj.io -A --all --ignore-not-found
oc delete workflowtasksets.argoproj.io -A --all --ignore-not-found
oc delete workflowtemplates.argoproj.io -A --all --ignore-not-found

# KServe
oc delete inferenceservices.serving.kserve.io -A --all --ignore-not-found
oc delete servingruntimes.serving.kserve.io -A --all --ignore-not-found
oc delete clusterservingruntimes.serving.kserve.io -A --all --ignore-not-found
oc delete clusterstoragecontainers.serving.kserve.io -A --all --ignore-not-found
oc delete inferencegraphs.serving.kserve.io -A --all --ignore-not-found
oc delete predictors.serving.kserve.io -A --all --ignore-not-found
oc delete trainedmodels.serving.kserve.io -A --all --ignore-not-found

# LLM-D
oc delete llminferenceserviceconfigs.serving.kserve.io -A --all --ignore-not-found
oc delete llminferenceservices.serving.kserve.io -A --all --ignore-not-found
oc delete inferencemodelrewrites.llm-d.ai -A --all --ignore-not-found
oc delete inferenceobjectives.llm-d.ai -A --all --ignore-not-found
oc delete inferencemodels.inference.networking.x-k8s.io -A --all --ignore-not-found
oc delete inferencepools.inference.networking.x-k8s.io -A --all --ignore-not-found
oc delete inferencepools.inference.networking.k8s.io -A --all --ignore-not-found

# Models as a Service (MaaS)
oc delete configs.maas.opendatahub.io -A --all --ignore-not-found
oc delete externalmodels.maas.opendatahub.io -A --all --ignore-not-found
oc delete maasauthpolicies.maas.opendatahub.io -A --all --ignore-not-found
oc delete maasmodelrefs.maas.opendatahub.io -A --all --ignore-not-found
oc delete maassubscriptions.maas.opendatahub.io -A --all --ignore-not-found
# aitenants and maastenantconfigs may get stuck
# recommend deleting the finalizer if they do
oc delete aitenants.maas.opendatahub.io -A --all --ignore-not-found
oc delete maastenantconfigs.maas.opendatahub.io -A --all --ignore-not-found 
oc delete tenants.maas.opendatahub.io -A --all --ignore-not-found
oc delete externalmodels.inference.opendatahub.io -A --all --ignore-not-found
oc delete externalproviders.inference.opendatahub.io -A --all --ignore-not-found

# Workbenches 
oc delete notebooks.kubeflow.org -A --all --ignore-not-found
# NOTE: Notebooks generally have a PVC associated with it that may need to be deleted as well

# Kubeflow Training Operator
oc delete jaxjobs.kubeflow.org -A --all --ignore-not-found
oc delete mpijobs.kubeflow.org -A --all --ignore-not-found
oc delete mxjobs.kubeflow.org -A --all --ignore-not-found
oc delete paddlejobs.kubeflow.org -A --all --ignore-not-found
oc delete pipelines.pipelines.kubeflow.org -A --all --ignore-not-found
oc delete pipelineversions.pipelines.kubeflow.org -A --all --ignore-not-found
oc delete pytorchjobs.kubeflow.org -A --all --ignore-not-found
oc delete scheduledworkflows.kubeflow.org -A --all --ignore-not-found
oc delete tfjobs.kubeflow.org -A --all --ignore-not-found
oc delete xgboostjobs.kubeflow.org -A --all --ignore-not-found
oc delete viewers.kubeflow.org -A --all --ignore-not-found


# TrustyAI
oc delete evalhubs.trustyai.opendatahub.io -A --all --ignore-not-found
oc delete guardrailsorchestrators.trustyai.opendatahub.io -A --all --ignore-not-found
oc delete lmevaljobs.trustyai.opendatahub.io -A --all --ignore-not-found
oc delete nemoguardrails.trustyai.opendatahub.io -A --all --ignore-not-found
oc delete trustyais.components.platform.opendatahub.io -A --all --ignore-not-found
oc delete trustyaiservices.trustyai.opendatahub.io -A --all --ignore-not-found

# Ray
oc delete rayclusters.ray.io -A --all --ignore-not-found
oc delete raycronjobs.ray.io -A --all --ignore-not-found
oc delete rayjobs.ray.io -A --all --ignore-not-found
oc delete rays.components.platform.opendatahub.io -A --all --ignore-not-found
oc delete rayservices.ray.io -A --all --ignore-not-found

# CodeFlare / App Wrappers
oc delete appwrappers.workload.codeflare.dev -A --all --ignore-not-found
oc delete codeflares.components.platform.opendatahub.io -A --all --ignore-not-found

# Feast
oc delete feastoperators.components.platform.opendatahub.io -A --all --ignore-not-found
oc delete featurestores.feast.dev -A --all --ignore-not-found

# LlamaStack
oc delete llamastackdistributions.llamastack.io -A --all --ignore-not-found
oc delete llamastackoperators.components.platform.opendatahub.io -A --all --ignore-not-found

# OGX
oc delete ogxs.components.platform.opendatahub.io -A --all --ignore-not-found
oc delete ogxservers.ogx.io -A --all --ignore-not-found

# MLflow
oc delete mlflowconfigs.mlflow.kubeflow.org -A --all --ignore-not-found
oc delete mlflowoperators.components.platform.opendatahub.io -A --all --ignore-not-found
oc delete mlflows.mlflow.opendatahub.io -A --all --ignore-not-found

# Spark
oc delete scheduledsparkapplications.sparkoperator.k8s.io -A --all --ignore-not-found
oc delete sparkapplications.sparkoperator.k8s.io -A --all --ignore-not-found
oc delete sparkconnects.sparkoperator.k8s.io -A --all --ignore-not-found
oc delete sparkoperators.components.platform.opendatahub.io -A --all --ignore-not-found

# Model registry / controllers
oc delete modelcontrollers.components.platform.opendatahub.io -A --all --ignore-not-found
oc delete modelmeshservings.components.platform.opendatahub.io -A --all --ignore-not-found
oc delete modelregistries.components.platform.opendatahub.io -A --all --ignore-not-found
oc delete modelregistries.modelregistry.opendatahub.io -A --all --ignore-not-found

# Kubeflow Training
oc delete trainers.components.platform.opendatahub.io -A --all --ignore-not-found
oc delete trainingoperators.components.platform.opendatahub.io -A --all --ignore-not-found

# RHOAI / ODH platform components
oc delete accounts.nim.opendatahub.io -A --all --ignore-not-found
oc delete aigateways.components.platform.opendatahub.io -A --all --ignore-not-found
oc delete applications.app.k8s.io -A --all --ignore-not-found
oc delete auths.services.platform.opendatahub.io -A --all --ignore-not-found
oc delete dashboards.components.platform.opendatahub.io -A --all --ignore-not-found
oc delete gatewayconfigs.services.platform.opendatahub.io -A --all --ignore-not-found
oc delete kserves.components.platform.opendatahub.io -A --all --ignore-not-found
oc delete kueues.components.platform.opendatahub.io -A --all --ignore-not-found
oc delete monitorings.services.platform.opendatahub.io -A --all --ignore-not-found
oc delete servicemeshes.services.platform.opendatahub.io -A --all --ignore-not-found
oc delete workbenches.components.platform.opendatahub.io -A --all --ignore-not-found

# RHOAI Core
oc delete datascienceclusters.datasciencecluster.opendatahub.io -A --all --ignore-not-found
oc delete dscinitializations.dscinitialization.opendatahub.io -A --all --ignore-not-found
oc delete featuretrackers.features.opendatahub.io -A --all --ignore-not-found
oc delete platforms.config.opendatahub.io -A --all --ignore-not-found
oc delete acceleratorprofiles.dashboard.opendatahub.io -A --all --ignore-not-found
oc delete hardwareprofiles.dashboard.opendatahub.io -A --all --ignore-not-found
oc delete hardwareprofiles.infrastructure.opendatahub.io -A --all --ignore-not-found
oc delete odhapplications.dashboard.opendatahub.io -A --all --ignore-not-found
oc delete odhdashboardconfigs.opendatahub.io -A --all --ignore-not-found
oc delete odhdocuments.dashboard.opendatahub.io -A --all --ignore-not-found
oc delete odhquickstarts.console.openshift.io -A --all --ignore-not-found
```

Subscription Cleanup
```
oc delete subscription rhods-operator -n redhat-ods-operator
oc delete operatorgroup --all -n redhat-ods-operator
oc delete clusterserviceversion --all -n redhat-ods-operator
oc delete installplan --all -n redhat-ods-operator
```

```
# Data Science Pipelines
oc delete crd datasciencepipelinesapplications.datasciencepipelinesapplications.opendatahub.io
oc delete crd datasciencepipelines.components.platform.opendatahub.io

# Argo Workflows
oc delete crd \
  clusterworkflowtemplates.argoproj.io \
  cronworkflows.argoproj.io \
  workflowartifactgctasks.argoproj.io \
  workfloweventbindings.argoproj.io \
  workflows.argoproj.io \
  workflowtaskresults.argoproj.io \
  workflowtasksets.argoproj.io \
  workflowtemplates.argoproj.io

# KServe
oc delete crd \
  inferenceservices.serving.kserve.io \
  servingruntimes.serving.kserve.io \
  clusterservingruntimes.serving.kserve.io \
  clusterstoragecontainers.serving.kserve.io \
  inferencegraphs.serving.kserve.io \
  predictors.serving.kserve.io \
  trainedmodels.serving.kserve.io

# LLM-D
oc delete crd \
  llminferenceserviceconfigs.serving.kserve.io \
  llminferenceservices.serving.kserve.io \
  inferencemodelrewrites.llm-d.ai \
  inferenceobjectives.llm-d.ai \
  inferencemodels.inference.networking.x-k8s.io \
  inferencepools.inference.networking.x-k8s.io \
  inferencepools.inference.networking.k8s.io

# Models as a Service (MaaS)
oc delete crd \
  aitenants.maas.opendatahub.io \
  configs.maas.opendatahub.io \
  externalmodels.maas.opendatahub.io \
  maasauthpolicies.maas.opendatahub.io \
  maasmodelrefs.maas.opendatahub.io \
  maassubscriptions.maas.opendatahub.io \
  maastenantconfigs.maas.opendatahub.io \
  tenants.maas.opendatahub.io \
  externalmodels.inference.opendatahub.io \
  externalproviders.inference.opendatahub.io

# Workbenches
oc delete crd notebooks.kubeflow.org

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
  viewers.kubeflow.org

# TrustyAI
oc delete crd \
  evalhubs.trustyai.opendatahub.io \
  guardrailsorchestrators.trustyai.opendatahub.io \
  lmevaljobs.trustyai.opendatahub.io \
  nemoguardrails.trustyai.opendatahub.io \
  trustyais.components.platform.opendatahub.io \
  trustyaiservices.trustyai.opendatahub.io

# Ray
oc delete crd \
  rayclusters.ray.io \
  raycronjobs.ray.io \
  rayjobs.ray.io \
  rays.components.platform.opendatahub.io \
  rayservices.ray.io

# CodeFlare / App Wrappers
oc delete crd appwrappers.workload.codeflare.dev
oc delete crd codeflares.components.platform.opendatahub.io

# Feast
oc delete crd feastoperators.components.platform.opendatahub.io
oc delete crd featurestores.feast.dev

# LlamaStack
oc delete crd llamastackdistributions.llamastack.io
oc delete crd llamastackoperators.components.platform.opendatahub.io

# OGX
oc delete crd \
  ogxs.components.platform.opendatahub.io \
  ogxservers.ogx.io

# MLflow
oc delete crd \
  mlflowconfigs.mlflow.kubeflow.org \
  mlflowoperators.components.platform.opendatahub.io \
  mlflows.mlflow.opendatahub.io

# Spark
oc delete crd \
  scheduledsparkapplications.sparkoperator.k8s.io \
  sparkapplications.sparkoperator.k8s.io \
  sparkconnects.sparkoperator.k8s.io \
  sparkoperators.components.platform.opendatahub.io

# Model registry / controllers
oc delete crd \
  modelcontrollers.components.platform.opendatahub.io \
  modelmeshservings.components.platform.opendatahub.io \
  modelregistries.components.platform.opendatahub.io \
  modelregistries.modelregistry.opendatahub.io

# Kubeflow Training
oc delete crd \
  trainers.components.platform.opendatahub.io \
  trainingoperators.components.platform.opendatahub.io

# RHOAI / ODH platform components
oc delete crd \
  accounts.nim.opendatahub.io \
  aigateways.components.platform.opendatahub.io \
  applications.app.k8s.io \
  auths.services.platform.opendatahub.io \
  dashboards.components.platform.opendatahub.io \
  gatewayconfigs.services.platform.opendatahub.io \
  kserves.components.platform.opendatahub.io \
  kueues.components.platform.opendatahub.io \
  monitorings.services.platform.opendatahub.io \
  servicemeshes.services.platform.opendatahub.io \
  workbenches.components.platform.opendatahub.io

# RHOAI Core
oc delete crd \
  datascienceclusters.datasciencecluster.opendatahub.io \
  dscinitializations.dscinitialization.opendatahub.io \
  featuretrackers.features.opendatahub.io \
  platforms.config.opendatahub.io \
  acceleratorprofiles.dashboard.opendatahub.io \
  hardwareprofiles.dashboard.opendatahub.io \
  hardwareprofiles.infrastructure.opendatahub.io \
  odhapplications.dashboard.opendatahub.io \
  odhdashboardconfigs.opendatahub.io \
  odhdocuments.dashboard.opendatahub.io \
  odhquickstarts.console.openshift.io

```


NS cleanup
```
oc delete project redhat-ods-applications
oc delete project redhat-ods-monitoring
oc delete project redhat-ods-operator
oc delete project rhods-notebooks
oc delete project models-as-a-service
oc delete project rehdat-ai-gateway-infra
oc delete project redhat-ods-model-registries
oc delete project opendatahub-ogx-system
oc delete project ai-tenants
```
