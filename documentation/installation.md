# Installing Red Hat OpenShift AI

This document contains the steps for installing and configuring Red Hat OpenShift AI (RHOAI) on your existing OpenShift cluster.

## Prerequisites

### OpenShift Cluster

Prior to deploying OpenShift AI, it is recommended you review the [Supported Configurations](https://access.redhat.com/articles/rhoai-supported-configs) documentation.

Ensure that you have cluster-admin access to an OpenShift cluster, since we will be installing several operators and configuring various components on the cluster.

The cluster must also have a functional storage provisioner available with a default StorageClass.

For GPU deployments, this repo is designed specifically to work with AWS to provision additional GPU nodes, but this can still act as an example to deploy GPU resources in any cloud environment or a self-hosted cluster with some minor modifications.

 > **_NOTE:_** Red Hat employees can request a demo cluster using [demo.redhat.com](https://demo.redhat.com) to provision OpenShift AI. For more information see the [Red Hat Demo Environment](redhat_demo_environment.md) documentation.

### Client Tooling

The bootstrap script relies on the following command line tools. If they're not already available on your system path, the bootstrap script will attempt to download them from the internet, and will place then in a `.\tmp` folder location where the bootstrap script was run:

- [oc](https://docs.openshift.com/container-platform/4.11/cli_reference/openshift_cli/getting-started-cli.html) - the OpenShift command-line interface (CLI) that allows for creation of applications, and can manage OpenShift Container Platform projects from a terminal.

- [kustomize](https://kubectl.docs.kubernetes.io/installation/kustomize/) - a Kubernetes configuration transformation tool that enables you to customize un-templated YAML files, leaving the original files untouched.

- [kubeseal](https://github.com/bitnami-labs/sealed-secrets#installation) - uses asymmetric crypto to encrypt secrets that only the controller can decrypt. These encrypted secrets are encoded in a SealedSecret resource, which you can see as a recipe for creating a secret.

- [openshift-install](https://github.com/openshift/installer/releases) (optional) - tooling that could be used for monitoring the [cluster installation progress](https://access.redhat.com/documentation/en-us/openshift_container_platform/4.11/html/installing/installing-on-a-single-node#install-sno-monitoring-the-installation-manually_install-sno-installing-sno-with-the-assisted-installer).

### Access to an OpenShift Cluster

Before running the bootstrap script, ensure that you have login access to your OpenShift cluster.

Make sure you are [logged into your cluster](https://docs.openshift.com/online/pro/cli_reference/get_started_cli.html) using the `oc login ...` command.  You can obtain a login token if required by utilizing the "Copy Login Command" found under your user profile in the OpenShift Web Console.

The scripts require a user with sufficient permissions for installing and configuring operators, typically the `kubeadmin` user account on a Red Hat Demo System hosted cluster.

## Bootstrapping a Cluster

Clone this git repository to a directory location on your local workstation, or to a [Bastion server](https://docs.openshift.com/container-platform/latest/networking/accessing-hosts.html) hosted within the OpenShift cluster subnet.

### Run the Cluster Bootstrap

Execute the bootstrap script to begin the installation process:

```sh
./scripts/bootstrap.sh
```

When prompted to select a bootstrap folder, choose the overlay that matches your cluster version, for example: `bootstrap/overlays/rhoai-eus-2.8/`.

The `bootstrap.sh` script will now install the OpenShift GitOps Operator, create an ArgoCD instance once the operator is deployed in the `openshift-gitops` namespace, then bootstrap a set of ArgoCD applications to configure the cluster.

Once the script completes, verify that you can access the ArgoCD UI using the URL output by the last line of the script execution. This URL should present an ArgoCD login page, showing that it was successfully deployed.

TODO: Add in details for the ArgoCD application menu tile within the OCP web console.

Alternatively you can also obtain the ArgoCD login URL from the ArgoCD route:

```sh
oc get routes openshift-gitops-server -n openshift-gitops
```

Use the OpenShift Login option and sign in with your OpenShift credentials.

The cluster may take 10-15 minutes to finish installing and updating.

## Updating the ArgoCD Groups

Argo creates the following group in OpenShift to grant access and control inside of ArgoCD:

- gitopsadmins

To add a user to the admin group run:

```sh
oc adm groups add-users argocdadmins $(oc whoami)
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
