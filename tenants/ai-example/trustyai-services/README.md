# TrustyAI Service

[TrustyAI](https://github.com/trustyai-explainability) Component is included in RedHat OpenShift AI and is enabled by default in DataScienceCluster custom resource.

To provide access to TrustyAI for all models deployed in data science project - TrustyAIService custom resource should be deployed.

This overlay deploys TrustyAIService CR's in the following namespaces provisioned as part of tenants/ai-example:
* ai-example-multi-model-serving
* ai-example-single-model-serving
* ai-example-training

Note that only one instance of TrustyAIService CR is required per namespace.

# Usage
To use TrustyAI monitoring capabilities - model bias or  drift metrics needs to be configured for a specific model.

# References
* RHOAI Docs: [Chapter 2. Configuring TrustyAI](https://docs.redhat.com/en/documentation/red_hat_openshift_ai_self-managed/2-latest/html/monitoring_data_science_models/configuring-trustyai_monitor)
* RHOAI Docs: [Chapter 4. Monitoring model bias](https://docs.redhat.com/en/documentation/red_hat_openshift_ai_self-managed/2-latest/html/monitoring_data_science_models/monitoring-model-bias_bias-monitoring)
* RHOAI Docs: [Chapter 5. Monitoring data drift](https://docs.redhat.com/en/documentation/red_hat_openshift_ai_self-managed/2-latest/html/monitoring_data_science_models/monitoring-data-drift_drift-monitoring)
* [TrustyAI Kubernetes Operator](https://github.com/trustyai-explainability/trustyai-service-operator)
* [OpenDataHub TrustyAI Demos](https://github.com/trustyai-explainability/odh-trustyai-demos)

