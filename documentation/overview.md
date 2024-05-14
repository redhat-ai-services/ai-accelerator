# AI Accelerator Project Overview

A GitOps approach to continuous delivery enables teams to deploy micro service based applications using a set of YAML files held within a Git repository. Red Hat OpenShift GitOps facilitates the consistent and automated deployment of Git based resources, to a selection of environments on Kubernetes platforms as content progresses from development to production.

This project structure is based on the opinionated configuration found [here](https://github.com/gnunn-gitops/standards/blob/master/folders.md). We highly recommend reading mode about the breakdown of the intention of this folder structure within that article.

## Repository Structure

```sh
.
├── bootstrap                             # used to for initial provisioning
├── clusters                              # used to define a running configuration
├── components                            # configurations in Kustomize and YAML
│   ├── argocd                            # yaml defenitions for argocd objects such as Applications and Projects
│   ├── cluster-configs                   # cluster level configurations
│   └── operators                         # operator subscriptions and configurations
├── documentation                         # various documentation, software groups
│   ├── images
│   └── operators
├── scripts                               # scripts to automate maintence tasks
└── tenants                               # configurations for end user namespaces and resources
```

## Bootstrap

The bootstrap folder contains the initial set of resources utilized to deploy the cluster.

## Clusters

The `clusters` folder contains the main aggregation layer for all of the elements of the cluster. This includes a `base` folder containing common elements, as well as cluster/environment specific configuration.

These overlays are contains in sub-directories that include a kustomization.yaml file. The Kustomization file contains a set of references to other kustomization directories as bases. Each Kustomization file that is referenced will either have another overlay or a base definition, as illustrated in the following figure:

![Kustomize and ArgoCD.jpeg](images/Kustomize%20and%20ArgoCD.jpeg)

It's expected that you will copy some of these examples and adapted them for your specific requirements for an installation of RHOAI on your OpenShift clusters - however you can also use these "as-is" for a demonstration cluster.

## Components

Components contains the bulk of the configuration.

- argocd
- operators
- cluster-configs

The opinionated configuration referenced above recommends several other folders in the `components` folder that we are not utilizing today but may be useful to add in the future.

### ArgoCD

The argocd folder contains the ArgoCD specific objects needed to configure the items in the apps folder.  The folders inside of Argo represent the different custom resources ArgoCD supports and refer back to objects in the `apps` folder.

### Operators

Operators contain the operators we wish to configure on the cluster and the details of how we would like them to be configured.

The operators folder general follows a pattern where each folder in `operators` is intended to be a separate ArgoCD application.  The majority of the folder structure utilized inside of those folders is a direct reference to the [redhat-cop/gitops-catalog](https://github.com/redhat-cop/gitops-catalog).  When attempting to add new operators to the cluster, be sure to check there first and feel free to contribute new components back to the catalog as well.

### Cluster Configs

TODO

## Scripts

Contains the shell scripts used to initialize the installation.

## References

* [Enterprise MLOps Reference Design](https://www.redhat.com/en/blog/enterprise-mlops-reference-design)
* [Your Guide to Continuous Delivery with OpenShift GitOps and Kustomize](https://www.redhat.com/en/blog/your-guide-to-continuous-delivery-with-openshift-gitops-and-kustomize)
* Red Hat COP [GitOps Catalog](https://github.com/redhat-cop/gitops-catalog)
