`oc login` into cluster

Run `./bootstrap.sh` to install GitOps, RHOAI, and other operators.
May need to run bootstrap.sh again if installing components is slow.


https://rh-aiservices-bu.github.io/rhoai-rh1-testdrive/modules/setup/enabling-data-science-pipelines.html



## Rolebased Access Controls for RHOAI:

https://access.redhat.com/documentation/en-us/red_hat_openshift_ai_self-managed/2-latest/html-single/managing_users/index

By default, all OpenShift users have access to Red Hat OpenShift AI. In addition, users with the cluster-admin role, automatically have administrator access in OpenShift AI.

The groups that you want to define as administrator and user groups for OpenShift AI need to already exist in OpenShift.
