# Red Hat AI Accelerator

Welcome to the AI Accelerator project source code. This project is designed to initialize an OpenShift cluster with a recommended set of operators and components that aid with training, deploying, serving and monitoring Machine Learning models.

This repo is intended to provide a core set of OpenShift features that would commonly be used for a Data Science environment, but can also be highly customized for specific scenarios. When starting out we recommend making a copy or a fork of this project on your Git based instance, since it utilizes the process of automating IT infrastructure using infrastructure as code and software development best practices such as Git, code review, and CI/CD - known as GitOps.

Once the initial components are deployed, several ArgoCD Application objects are created which are then used to install and manage the install of the operators on the cluster.

![AI Accelerator Overview](documentation/diagrams/AI_Accelerator.drawio.png)

## Additional Documentation and Info

* [Overview](documentation/overview.md) - what's inside this repository?
* [Installation Guide](documentation/installation.md) - containing step by step instructions for executing this installation sequence on your cluster

### Operators

* [Authorino Operator](components/operators/authorino-operator/)
* [CloudNativePG Operator](components/operators/cloudnative-pg/)
* [Cluster Observability Operator](components/operators/cluster-observability-operator/)
* [Kiali Operator](components/operators/kiali-operator/)
* [Leader Worker Set Operator](components/operators/leader-worker-set/)
* [NVIDIA GPU Operator](components/operators/gpu-operator-certified/)
* [Node Feature Discovery Operator](components/operators/nfd/)
* [OpenShift AI](components/operators/openshift-ai/)
* [OpenShift Custom Metrics Autoscaler](components/operators/openshift-custom-metrics-autoscaler/)
* [OpenShift External Secrets Operator](components/operators/openshift-external-secrets-operator/)
* [OpenShift GitOps](components/operators/openshift-gitops/)
* [OpenShift JobSet](components/operators/openshift-jobset/)
* [OpenShift Pipelines](components/operators/openshift-pipelines/)
* [OpenShift Serverless](components/operators/openshift-serverless/)
* [OpenShift ServiceMesh](components/operators/openshift-servicemesh/)
* [Red Hat Build of Kueue](components/operators/redhat-build-of-kueue/)
* [Red Hat Build of OpenTelemetry](components/operators/redhat-build-of-opentelemetry/)
* [Red Hat Connectivity Link](components/operators/redhat-connectivity-link/)
* [Tempo Operator](components/operators/tempo-operator/)

### Applications

* OpenShift GitOps: [ArgoCD](components/argocd/)

### Configuration

* [Bootstrap Overlays](bootstrap/overlays/)
* [Cluster Configuration Sets](clusters/overlays/)

### Example Applications

Looking for example applications to deploy on top of OpenShift AI?

You can find example workloads here:

[AI Accelerator Examples](http://github.com/redhat-ai-services/ai-accelerator-examples)
