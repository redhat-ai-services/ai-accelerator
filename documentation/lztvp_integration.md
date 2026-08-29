# Integrating with the Layered Zero Trust Validated Pattern
The [Layered Zero Trust Validated Pattern](https://validatedpatterns.io/patterns/layered-zero-trust/)(LZTVP) is a GitOps-applied project that shows how to implement zero trust in a Red Hat OpenShift Container Platform environment. Because this pattern and the ai-accelerator both use GitOps, there are some modifications to this ai-accelerator repository that must be done in order for the two to work together.

## Background
Validated Patterns will disable the default ArgoCD instance (`openshift-gitops`) which is also the default deployment location for the ai-accelerator. Because of this behavior, there is a specific way to set up the default GitOps instance for it to work with the pattern and the ai-accelerator. This guide assumes that you are following that approach, and not targeting a different Argo instance for the ai-accelerator applications.

Due to the LZTVP also configuring the GitOps operator, modifications must be made to this repository to relinquish configuration of it. That is what this guide does: informs you how to deploy all of the features of the ai-accelerator with the exception of the gitops-operator, since the LZTVP will control it.

### Procedure
1. Follow the installation instructions here to install the LZTVP. Wait for all those Argo Applications to show synchronized before proceeding.
1. Fork the ai-accelerator (you will need to make modifications to this repository)
1. Look at the contents of the [overlays directory](../bootstrap/overlays/) to determine the profile that will be used. Subsequent changes will use this profile.
1. Navigate to your chosen profile in the [argo components directory](../components/argocd/apps/overlays/) and comment out or delete the `openshift-gitops-operator` application in the `patch-operators-list.yaml`. 
    ```yaml 
            <...>
          - cluster: local
            url: https://kubernetes.default.svc
            values:
            name: openshift-gitops-operator
            path: components/operators/openshift-gitops/aggregate/overlays/rhdp
        # Comment out or delete this to let LZTVP own the gitops operator
        # - cluster: local
        #   url: https://kubernetes.default.svc
        #   values:
        #     name: openshift-gitops-operator
        #     path: components/operators/openshift-gitops/aggregate/overlays/rhdp
        - cluster: local
            url: https://kubernetes.default.svc
            values:
            <...>
1. Open [components/operators/openshift-gitops/instance/base/kustomization.yaml](../components/operators/openshift-gitops/instance/base/kustomization.yaml) and comment out the `resources` yaml
    ```yaml
    namespace: openshift-gitops

    # Comment or delete the resources block to not enable the GitOps application
    # resources:
    #   - openshift-gitops.yaml
    ```
1. Open [components/operators/openshift-gitops/instance/overlays/rhdp/kustomization.yaml](../components/operators/openshift-gitops/instance/overlays/rhdp/kustomization.yaml) and delete or comment out all of the `components` and `patches`.
    ```yaml
    resources:
    - ../../base
    # Comment out components so they are not loaded
    # components:
    #   - ../../components/annotation-resource-tracking
    # 
    #<...>
    #    - ../../components/kustomize-build-enable-helm

    # patches:
    #   - path: gitops-admins-group.yaml
    ```
1. Run the [validation script](../scripts/validate_manifests.sh) to confirm that your changes are valid. Then push them to your fork. 
1. Deploy the accelerator as described by the installation instructions [here](installation.md). Once everything is installed, you should see several applications in your cluster's `Cluster Argo CD` instance. 