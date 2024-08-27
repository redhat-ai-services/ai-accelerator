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

The `bootstrap` folder contains the initial set of resources utilized to deploy the cluster.

## Clusters

The `clusters` folder contains the main aggregation layer for all of the elements of the cluster. This includes a `base` folder containing common elements, as well as cluster/environment specific configuration.

These overlays are contained in sub-directories that include a `kustomization.yaml` file. The [Kustomization](https://kustomize.io/) file contains a set of references to other base directories. Each Kustomization file that is referenced will either have another overlay or a base definition, as illustrated in the following figure:

![Kustomize and ArgoCD.jpeg](images/Kustomize%20and%20ArgoCD.jpeg)

> [!NOTE]  
> These examples are designed to be customized to fit the specific requirements for an installation of RHOAI on your OpenShift clusters. However they are usable "as-is" for a demonstration cluster.

> [!IMPORTANT]  
> If repo was cloned, make sure to update the git url in `clusters/overlays/rhoai-xxx/patch-application-repo-revision` to point to your repository.

## Components

The `components` folder contains the bulk of the configuration.

> [!NOTE]  
> Other folders may be required based on the configuration reference above and individual team's requirements

### ArgoCD

The `argocd` folder is used for ArgoCD related objects and contains an `apps` and `projects` folder.

#### Apps

A set of ArgoCD Application and ApplicationSets used to install the required components.

#### Project

A set of ArgoCD Projects setting up basic RBAC at the ArgoCD layer.

### Operators

The `operators` folder contains objects for the installation and configuration of the operators required on the cluster.

> [!TIP]  
> The `operators` folder general follows a pattern where each subfolder is intended to be a separate ArgoCD application. Most of the examples on this repository were pulled directly from [redhat-cop/gitops-catalog](https://github.com/redhat-cop/gitops-catalog).  
>
> If other operators are required check there first. And feel free to contribute new components back to the catalog as well! :smiley:

### Cluster-Configs

The `cluster-configs` folder contains suggested configuration files for features that come default with Openshift, such as work load monitoring.

## Scripts

The `scripts` folder contains shell scripts used to initialize the installation.

## Documentation

The `documentation` folder contains the public documentation associated with this repository.

## References

* [Enterprise MLOps Reference Design](https://www.redhat.com/en/blog/enterprise-mlops-reference-design)
* [Your Guide to Continuous Delivery with OpenShift GitOps and Kustomize](https://www.redhat.com/en/blog/your-guide-to-continuous-delivery-with-openshift-gitops-and-kustomize)
* Red Hat COP [GitOps Catalog](https://github.com/redhat-cop/gitops-catalog)
