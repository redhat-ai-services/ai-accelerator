
## Pipelines:

[Enabling Data Science Pipelines](https://rh-aiservices-bu.github.io/rhoai-rh1-testdrive/modules/setup/enabling-data-science-pipelines.html)

## Notebook Culling:
[Managing Notebook Servers](https://access.redhat.com/documentation/vi-vn/red_hat_openshift_data_science/1/html/managing_users_and_user_resources/managing_notebook_servers)

In RHOAI Dashboard>Settings>Cluster Settings>Stop idle notebooks:
When enabled is selected and saved, the ConfigMap below will be created. You can enable culling outside of RHOAI Dashboard by applying this ConfigMap to `redhat-ods-applications` namespace.

Apply ConfigMap in `redhat-ods-applications`.
__CULL_IDLE_TIME__ and __IDLENESS_CHECK_PERIOD__ is in minutes. __ENABLE_CULLING__ is false by default.

```
kind: ConfigMap
apiVersion: v1
metadata:
  name: notebook-controller-culler-config
  namespace: redhat-ods-applications
  labels:
    opendatahub.io/dashboard: 'true'
data:
  CULL_IDLE_TIME: '60'
  ENABLE_CULLING: 'true'
  IDLENESS_CHECK_PERIOD: '1'
```

NOTE: In RHOAI Dashboard>Settings>Cluster Settings>Stop idle notebooks
If culling is enabled by ConfigMap, but then disabled in RHOAI Dashboard settings. The ConfigMap `notebook-controller-culler-config` will be deleted. 

## Default Jupyter PVC size:
[Default PVC Sizes](https://access.redhat.com/documentation/vi-vn/red_hat_openshift_data_science/1/html/managing_users_and_user_resources/configuring-the-default-pvc-size-for-your-cluster_user-mgmt)

## Configuring additional model serving runtimes:
[Configuring Additional Runtimes](https://access.redhat.com/documentation/en-us/red_hat_openshift_ai_self-managed/2.6/html/serving_models/serving-small-and-medium-sized-models_model-serving)

Red Hat OpenShift AI includes a single model serving platform that is based on the KServe component.

You must first make sure that you have properly installed the necessary component of the Single-Model Serving stack, as documented here: [Serving Large Models](https://access.redhat.com/documentation/en-us/red_hat_openshift_ai_self-managed/2-latest/html/serving_models/serving-large-models_serving-large-models).

Once the stack is installed, adding the runtime is pretty straightforward:

- As an admin, in the OpenShift AI Dashboard, open the menu Settings -> Serving runtimes.
- Click on Add serving runtime.
- For the type of model serving platforms this runtime supports, select Single model serving platform.
- Upload the serving-runtime.yaml from the current folder, or click Start from scratch and copy/paste its content.

The runtime is now available when deploying a model.

## Role Based Access Controls for RHOAI:
By default, all OpenShift users have access to Red Hat OpenShift AI. In addition, users with the cluster-admin role, automatically have administrator access in OpenShift AI.

The groups that you want to define as administrator and user groups for OpenShift AI need to already exist in OpenShift.

By default, in OpenShift, only OpenShift admins can edit group membership. Being a RHOAI Admin does not confer you those admin privileges, and so, it would fall to the OpenShift admin to administer that list.

These instructions will show how the OpenShift Admin can create these groups in such a way that any member of the group `rhods-admins` can edit the users listed in the group `rhoai-users`. These makes the RHOAI Admins more self-sufficient, without giving them unneeded access.

Create the RHOAI groups:
`oc adm groups new rhoai-users` 
`oc adm groups new rhoai-admins` ## `rhods-admins` created by operator. Changed name and should be updated.

Confirm groups were created: `oc get groups | grep rhoai`

Create the Cluster Role and Cluster Role Binding:

```yaml
oc apply -f - <<EOF
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRole
metadata:
  name: update-rhoai-users
rules:
  - apiGroups: ["user.openshift.io"]
    resources: ["groups"]
    resourceNames: ["rhoai-users"]
    verbs: ["update", "patch", "get"]
---
kind: ClusterRoleBinding
apiVersion: rbac.authorization.k8s.io/v1
metadata:
  name: rhoai-admin-can-update-rhoai-users
subjects:
  - kind: Group
    apiGroup: rbac.authorization.k8s.io
    name: rhoai-admins
roleRef:
  apiGroup: rbac.authorization.k8s.io
  kind: ClusterRole
  name: update-rhoai-users
EOF
```

To confirm cluster role and cluster role binding were created successfully:
`oc get ClusterRole,ClusterRoleBinding  | grep 'update\-rhoai'`

RHOAI admins can now add users.

Make sure the `rhoai-users` group is added in the Data Science user groups: RHOAI > Settings > User Management> Data Science user groups

RHOAI Dashboard > Settings > User Management:

![Add Groups in RHOAI](./readme_images/add_groups_RHOAI.png "Add Groups in RHOAI")

Documentation:
[Managing Users](https://access.redhat.com/documentation/en-us/red_hat_openshift_ai_self-managed/2-latest/html-single/managing_users/index)
[OpenShift Group Management](https://ai-on-openshift.io/odh-rhoai/openshift-group-management/)

## Role Based Access Controls for RHOAI Projects:
To add Groups or specific users to a RHOAI project, set up a role binding as such below:
```
kind: RoleBinding
apiVersion: rbac.authorization.k8s.io/v1
metadata:
  name: dashboard-permissions-ai-test-group
  namespace: ai-example-project
  labels:
    opendatahub.io/dashboard: 'true'
    opendatahub.io/project-sharing: 'true'
subjects:
  - kind: Group
    apiGroup: rbac.authorization.k8s.io
    name: test-group
roleRef:
  apiGroup: rbac.authorization.k8s.io
  kind: ClusterRole
  name: edit ##or admin
```

For Users:
```
kind: RoleBinding
apiVersion: rbac.authorization.k8s.io/v1
metadata:
  name: dashboard-permissions-user1
  namespace: ai-example-project
  labels:
    opendatahub.io/dashboard: 'true'
    opendatahub.io/project-sharing: 'true'
subjects:
  - kind: User
    apiGroup: rbac.authorization.k8s.io
    name: user1
roleRef:
  apiGroup: rbac.authorization.k8s.io
  kind: ClusterRole
  name: edit ##or admin
```

## Non-GitOps Installation
Install supporting operators from `nongitops_yaml/operators/`:

* After Elastic Search operator is created, make sure to apply the `cluster-monitoring-config.yaml`.

Install RHOAI in the `nongitops_yaml/rhoai/` folder:

1. Apply `rhoai-operator.yaml` first. 
    This creates the `redhat-ods-operator` namespace for the RHOAI operator.
    And installs the RHOAI operator.

2. Apply the `datasciencecluster.yaml`.
    This creates a DataScienceCluster instance for RHOAI.
    (You can edit the yaml to enable or disable features.)
    This also creates the DSCInitialization instance for RHOAI.

3. Apply the `ds-sample-project-ns.yaml`.
    This creates a Data Science Project in RHOAI.
    This is a namespace manifest with the label: `opendatahub.io/dashboard: 'true'`