`oc login` into cluster

Run `./bootstrap.sh` to install GitOps, RHOAI, and other operators.
May need to run bootstrap.sh again if installing components is slow.


https://rh-aiservices-bu.github.io/rhoai-rh1-testdrive/modules/setup/enabling-data-science-pipelines.html



## Rolebased Access Controls for RHOAI:
By default, all OpenShift users have access to Red Hat OpenShift AI. In addition, users with the cluster-admin role, automatically have administrator access in OpenShift AI.

The groups that you want to define as administrator and user groups for OpenShift AI need to already exist in OpenShift.

By default, in OpenShift, only OpenShift admins can edit group membership. Being a RHOAI Admin does not confer you those admin privileges, and so, it would fall to the OpenShift admin to administer that list.

These instructions will show how the OpenShift Admin can create these groups in such a way that any member of the group rhods-admins (rhoai-admins) can edit the users listed in the group rhoai-users. These makes the RHOAI Admins more self-sufficient, without giving them unneeded access.

Create the rhoai groups:
`oc adm groups new rhoai-users` 
`oc adm groups new rhoai-admins` ## rhods-admins created by operator. Changed name and should be updated.

Confirm groups were created: `oc get groups | grep rhoai`

Create the Cluster Role and Cluster Role Binding:
```
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

Make sure the rhoai-users group is added in the Data Science user groups: RHOAI>Settings>User Management>Data Science user groups

RHOAI Dashboard > Settings > User Management:

![Add Groups in RHOAI](./readme_images/add_groups_RHOAI.png "Add Groups in RHOAI")

Documentation:
https://access.redhat.com/documentation/en-us/red_hat_openshift_ai_self-managed/2-latest/html-single/managing_users/index
https://ai-on-openshift.io/odh-rhoai/openshift-group-management/
