# Red Hat OpenShift AI

Install Red Hat OpenShift AI.

Do not use the `base` directory directly, as you will need to patch the `channel` based on the version of OpenShift you are using, or the version of the operator you want to use.

The current *overlays* available are for the following channels:

* [beta](operator/overlays/beta)
* [eus-2.16](operator/overlays/eus-2.16)
* [eus-2.25](operator/overlays/eus-2.25)
* [eus-3.5](operator/overlays/eus-3.5)
* [stable](operator/overlays/stable)
* [stable-3.3](operator/overlays/stable-3.3)
* [stable-3.4](operator/overlays/stable-3.4)
* [stable-3.x](operator/overlays/stable-3.x)

## Usage

If you have cloned the `gitops-catalog` repository, you can install Red Hat OpenShift AI based on the overlay of your choice by running from the root (`gitops-catalog`) directory.

```
oc apply -k openshift-ai/operator/overlays/<channel>
```

Or, without cloning:

```
oc apply -k https://github.com/redhat-cop/gitops-catalog/openshift-ai/operator/overlays/<channel>
```

As part of a different overlay in your own GitOps repo:

```
apiVersion: kustomize.config.k8s.io/v1beta1
kind: Kustomization
resources:
  - https://github.com/redhat-cop/gitops-catalog/openshift-ai/operator/overlays/<channel>?ref=main
```

## Instance and Aggregation Overlays

Beyond the operator subscriptions, this component also contains the following folders:

* [instance-2.x](instance-2.x/) - configuration for the RHOAI 2.x `DataScienceCluster` and related resources
* [instance-3.x](instance-3.x/) - configuration for the RHOAI 3.x `DataScienceCluster`, `DSCInitialization` and related resources, including a set of composable components for enabling and configuring each part of the stack
* [aggregate](aggregate/) - overlays that combine the operator and instance configurations for a specific RHOAI release, such as `eus-3.5-nvidia-gpu`
