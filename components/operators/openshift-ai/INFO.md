# openshift-ai

Red Hat OpenShift AI is a complete platform for the entire lifecycle of your AI/ML projects.

When using Red Hat OpenShift AI, your users will find all the tools they would expect from a modern AI/ML platform in an interface that is intuitive, requires no local install, and is backed by the power of your OpenShift cluster.

Your Data Scientists will feel right at home with quick and simple access to the Notebook interface they are used to. They can leverage the default Notebook Images (Including PyTorch, tensorflow, and CUDA), or add custom ones. Your MLOps engineers will be able to leverage Data Science Pipelines to easily parallelize and/or schedule the required workloads. They can then quickly serve, monitor, and update the created AI/ML models. They can do that by either using the provided out-of-the-box vLLM Model Serving Runtimes or by adding their own custom serving runtime instead. These activities are tied together with the concept of Data Science Projects, simplifying both organization and collaboration.

But beyond the individual features, one of the key aspects of this platform is its flexibility. Not only can you augment it with your own Customer Workbench Image and Custom Model Serving Runtime Images, but you will also have a consistent experience across any infrastructure footprint. Be it in the public cloud, private cloud, on-premises, and even in disconnected clusters. Red Hat OpenShift AI can be installed on any supported OpenShift. It can scale out or in depending on the size of your team and its computing requirements.

Finally, thanks to the operator-driven deployment and updates, the administrative load of the platform is very light, leaving everyone more time to focus on the work that makes a difference.

## Components

The list below reflects the stack deployed by the `DataScienceCluster` resource managed by this repository. Each component maps to a configuration found in the [instance-3.x](instance-3.x/) folder.

### Core Platform

* **Dashboard** - web UI for managing Data Science Projects and accessing the platform tools
* **Workbenches** - interactive Jupyter-based development environments, deployed to the `rhods-notebooks` namespace
* **AI Pipelines** - Data Science Pipelines for building, deploying and managing end-to-end ML workflows

### Model Serving

* **KServe** - model serving using raw Kubernetes Deployments with a headed service configuration (`rawDeploymentServiceConfig: Headed`)
* **WVA (Workload Variance Autoscaling)** - autoscaling capabilities for KServe and `LLMInferenceServices`
* **AI Gateway with Models-as-a-Service (MaaS)** - simplified model serving experience with automatic Gateway configuration for inference endpoints
* The legacy KServe `modelsAsService` and `nim` serving options are not deployed (removed in favor of AI Gateway MaaS)

### Model Lifecycle

* **Model Registry** - index and manage models, versions, and artifacts metadata, deployed to the `rhoai-model-registries` namespace
* **MLflow Operator** - ML lifecycle management, including a basic shared MLflow instance for the cluster
* **Feast Operator** - open source feature store for managing, storing and serving ML features

### Distributed Workloads

* **Ray** - distributed computing for scaling AI/Python applications, distributed training and hyperparameter tuning
* **Training Operator** - Kubeflow Training Operator for distributed training jobs (PyTorch, TensorFlow, etc.)
* **Kueue** - job queueing and scheduling, deployed `Unmanaged` so the `ClusterQueue` and `LocalQueue` configuration is owned by the cluster administrator (queue auto-creation is disabled and both default to the `default` queue names)

### Responsible AI and GenAI

* **TrustyAI** - explainability (XAI) capabilities for machine learning models, including LM Eval with code execution and online evaluation denied by default for security
* **OGX** - tooling for building generative AI applications, including Retrieval-Augmented Generation (RAG) and agentic workflows, with support for remote inference, embeddings, and vector database operations

### Not Deployed

* **LlamaStack Operator** - available as an optional component in [instance-3.x/components/components-llamastack](instance-3.x/components/components-llamastack/) but removed from the deployed stack
