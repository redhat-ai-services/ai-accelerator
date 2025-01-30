# Installing Red Hat OpenShift AI

This document contains the steps for installing and configuring Red Hat OpenShift AI (RHOAI) on your existing OpenShift cluster.

## Prerequisites

### OpenShift Cluster

- (Recommended) Review [Supported Configurations](https://access.redhat.com/articles/rhoai-supported-configs) documentation.

- Account with appropriate permissions for installing operator and configuration installation (typically `kubeadmin`).

- Functional storage provisioner available with a default StorageClass.

> [!Note]  
> If using GPUs (not required): This repo is designed and tested to work with AWS for provisioning additional GPU nodes. 
> 
> Can still act as an example to deploy GPU resources in any cloud environment or a self-hosted cluster with some minor modifications.

> [!Tip]  
> Red Hat employees can request a demo cluster using [demo.redhat.com](https://demo.redhat.com) to provision OpenShift AI. For more information see the [Red Hat Demo Environment](redhat_demo_environment.md) documentation.

### Client Tooling

The following are required for the bootstrap scripts. If unavailable the scripts will attempt to download required tools and store them at `.\tmp`:

- [oc](https://docs.redhat.com/en/documentation/openshift_container_platform/latest/html-single/cli_tools/index#cli-getting-started) - OpenShift command-line interface (CLI).

- [kustomize](https://kubectl.docs.kubernetes.io/installation/kustomize/) - Kubernetes native configuration and transformation tool.

- [kubeseal](https://github.com/bitnami-labs/sealed-secrets#overview) - Encryption tool used for creating the SealedSecret resource.

- [openshift-install](https://github.com/openshift/installer/releases) (optional) - Tool used for monitoring the [cluster installation progress](https://docs.redhat.com/en/documentation/openshift_container_platform/4.17/html-single/installing_on_any_platform/index#installation-installing-bare-metal_installing-platform-agnostic).

- [yq](https://github.com/mikefarah/yq?tab=readme-ov-file#install) - a lightweight and portable command-line YAML, JSON and XML processor. Used by installation scripts when working with configuration files. WARNING!! The yq python implementation does not work. Ensure to use the implementation from this mentioned GitHub repository.

### Access to an OpenShift Cluster

Login to the cluster using `oc login...` using an account with appropriate permissions.

## Bootstrapping a Cluster

Clone this git repository to a directory location on your local workstation, or to a [Bastion server](https://docs.redhat.com/en/documentation/openshift_container_platform/4.17/html-single/networking/index#accessing-hosts) hosted within the OpenShift cluster subnet.

### Run the Cluster Bootstrap

Execute the bootstrap script to begin the installation process:

```sh
./bootstrap.sh
```
The script defaults to using the central repository at `(https://github.com/redhat-ai-services/ai-accelerator.git)` and the main branch for GitOps configuration. If your working remote repository differs, the script will prompt you to update the GitOps configuration to match. Selecting this option will:

- Update the repository and branch in `cluster-config-app-of-apps`.
- Commit the changes locally.
- Require you to push the updated file `cluster-config-app-of-apps` in the main branch of your remote central repository before submitting a pull request.

When prompted to select a bootstrap folder, choose the overlay that matches your cluster version, for example: `bootstrap/overlays/rhoai-eus-2.8/`.

The `bootstrap.sh` script will :
- check for an existing OpenShift GitOps Operator installation
- install the OpenShift GitOps Operator if there is not already an existing installation and create an ArgoCD instance once the operator is deployed in the `openshift-gitops` namespace
- bootstrap a set of ArgoCD applications to configure the cluster.

Once the script completes, verify that you can access the ArgoCD UI using the URL output by the last line of the script execution.

This URL should present an ArgoCD login page, showing that it was successfully deployed.

TODO: Add in details for the ArgoCD application menu tile within the OCP web console.

Alternatively you can also obtain the ArgoCD login URL from the ArgoCD route:

```sh
oc get routes openshift-gitops-server -n openshift-gitops
```

Use the OpenShift Login option and sign in with your OpenShift credentials.

The cluster may take 10-15 minutes to finish installing and updating.

## Updating the ArgoCD Groups

Argo creates the following group in OpenShift to grant access and control inside of ArgoCD:

- gitops-admins

To add a user to the admin group run:

```sh
oc adm groups add-users gitops-admins $(oc whoami)
```

To add a user to the user group run:

```sh
oc adm groups add-users argocdusers $(oc whoami)
```

Once the user has been added to the group logout of Argo and log back in to apply the updated permissions. Validate that you have the correct permissions by going to `User Info` menu inside of Argo to check the user permissions.

## Accessing Argo using the CLI

To log into ArgoCD using the `argocd` cli tool run the following command:

```sh
argocd login --sso <argocd-route> --grpc-web
```

## ArgoCD Troubleshooting

### Operator Shows Progressing for a Very Long Time

ArgoCD Symptoms:

Argo Applications and the child subscription object for operator installs show `Progressing` for a very long time.

Explanation:

Argo utilizes a `Health Check` to validate if an object has been successfully applied and updated, failed, or is progressing by the cluster.  The health check for the `Subscription` object looks at the `Condition` field in the `Subscription` which is updated by the `OLM`.  Once the `Subscription` is applied to the cluster, `OLM` creates several other objects in order to install the Operator.  Once the Operator has been installed `OLM` will report the status back to the `Subscription` object.  This reconciliation process may take several minutes even after the Operator has successfully installed.

Resolution/Troubleshooting:

- Validate that the Operator has successfully installed via the `Installed Operators` section of the OpenShift Web Console.
- If the Operator has not installed, additional troubleshooting is required.
- If the Operator has successfully installed, feel free to ignore the `Progressing` state and proceed.  `OLM` should reconcile the status after several minutes and Argo will update the state to `Healthy`.
