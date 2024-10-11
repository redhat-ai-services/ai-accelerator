# Disconnected Install of the ai-accelerator

You'll need to follow the [installation directions](https://github.com/redhat-ai-services/ai-accelerator/blob/main/documentation/installation.md)

Typically, in a disconnected installation there are two sides to the network, a low side security network that can talk to the world wide web, and
a high security network that can talk to the OCP cluster and the low side network but can not talk to the world wide web.  

The rest of this document will refer to the server that can manage with the disconnected OCP cluster as the "high side" and the server that can fetch
various resources as the low side. 

In general, the main additional work required is to download the necessary resources on the low side and then upload them to the high side for use
with the OCP cluster.

## Prerequisites

You'll need to get `kustomize` on your "high-side" by downloading on "low-side" and then rsync it up.
For example:
```
curl -s "https://raw.githubusercontent.com/kubernetes-sigs/kustomize/master/hack/install_kustomize.sh"  | bash
rysnc -avP /mnt/low-side-data/ highside:/mnt/high-side-data/
```

On high side put kustomize on the path, for example:
```
sudo cp /mnt/high-side-data/kustomize /bin/
```

### install kubeseal

On the low side
```
curl -L -o kubeseal-0.27.1-linux-amd64.tar.gz https://github.com/bitnami-labs/sealed-secrets/releases/download/v0.27.1/kubeseal-0.27.1-linux-amd64.tar.gz
rysnc -avP /mnt/low-side-data/ highside:/mnt/high-side-data/
```

And then on the high side, extract and place it on the path.
```
tar -xzvf kubeseal-0.27.1-linux-amd64.tar.gz 
sudo cp /mnt/high-side-data/kubeseal /bin/
```

### Clone this repo

Clone the repo ai-accelerator git repo on the low side and checkout this branch.

After that, you'll want to rsync the git repo to high side


### Login to the cluster on the high side

Login to your cluster as per [Access Instructions](https://github.com/redhat-ai-services/ai-accelerator/blob/main/documentation/installation.md#access-to-an-openshift-cluster)

## Syncing resources to OCP

Red Hat delivers a tool called `oc-mirror` to help with syncing images from registries to a private disconnected registry.  

To learn more about oc-mirror visit https://docs.openshift.com/container-platform/4.16/installing/disconnected_install/installing-mirroring-disconnected.html

This write up utilized oc-mirror v1; there is currently a newer version (v2) that is in technology preview.

### Common pitfalls

#### Disk utilization
The mirroring process utilizes a large amount of disk space during this process, we required 250GB of available 
disk space for downloading the images, creating the oc-mirror workspace and finally the tar containing the images 
for loading the mirror.  On the high side, we required at least 450 GB.

#### Missing images
See 
https://docs.openshift.com/container-platform/4.16/installing/disconnected_install/installing-mirroring-disconnected.html#oc-mirror-updating-cluster-manifests_installing-mirroring-disconnected

### ImageSetConfiguration

You'll need to define an ImageSetConfiguration for oc-mirror to know what images to download and package for the mirror.

Below is an example of this

```
kind: ImageSetConfiguration
apiVersion: mirror.openshift.io/v1alpha2
storageConfig:
  local:
    path: ./
mirror:
  platform:
    channels:
    - name: stable-4.14
      type: ocp
      minVersion: 4.14.19
      maxVersion: 4.14.20

  operators:
  - catalog: registry.redhat.io/redhat/redhat-operator-index:v4.14
    packages:
    - name: web-terminal
      channels:
      - name: fast
    - name: openshift-pipelines-operator-rh
      channels:
      - name: latest
    - name: serverless-operator
      channels:
      - name: stable
    - name: servicemeshoperator
      channels:
      - name: stable
    - name: authorino-operator
      channels:
      - name: tech-preview-v1
    - name: openshift-gitops-operator
      channels:
      - name: latest
    - name: rhods-operator
      channels:
      - name: fast
        minVersion: 2.11.0
        maxVersion: 2.11.0

  additionalImages:
    - name: registry.redhat.io/rhel8/support-tools
    - name: quay.io/integreatly/prometheus-blackbox-exporter@sha256:35b9d2c1002201723b7f7a9f54e9406b2ec4b5b0f73d114f47c70e15956103b5
    - name: quay.io/modh/caikit-nlp@sha256:0cde6c26e02ec398aea959a1a1bcdc615b86821adb41989e81d03de01124545c
    - name: quay.io/modh/caikit-tgis-serving@sha256:4e907ce35a3767f5be2f3175a1854e8d4456c43b78cf3df4305bceabcbf0d6e2
    - name: quay.io/modh/codeserver@sha256:cf69c38ccc64f79572805e51c2f1f9000e44b26033f577eb8cd2957a32a997c3
    - name: quay.io/modh/codeserver@sha256:d0b809b14ccb0fe8df98c0a20a7cdc1fe868beb31f837bc440cc641d5a3be5c9
    - name: quay.io/modh/cuda-notebooks@sha256:00c53599f5085beedd0debb062652a1856b19921ccf59bd76134471d24c3fa7d
    - name: quay.io/modh/cuda-notebooks@sha256:500029c74d8e54a9cf29b900059aa33f1b9582927bb3628ebb8891d3efaf6896
    - name: quay.io/modh/cuda-notebooks@sha256:6fadedc5a10f5a914bb7b27cd41bc644392e5757ceaf07d930db884112054265
    - name: quay.io/modh/cuda-notebooks@sha256:81622e37771d341e119a2e55f09ffaf7837ad73af3602d2817d54ed53ea65665
    - name: quay.io/modh/cuda-notebooks@sha256:88d80821ff8c5d53526794261d519125d0763b621d824f8c3222127dab7b6cc8
    - name: quay.io/modh/cuda-notebooks@sha256:eb02f5fc5f18697fb36b9c3837183fd22c4ac5a9e5afa377d132e73bff16dc8d
    - name: quay.io/modh/cuda-notebooks@sha256:f2282968cd8aa26b362cccfa2a880e30ac2661fa1cdc13118623758e205776b0
    - name: quay.io/modh/cuda-notebooks@sha256:f6cdc993b4d493ffaec876abb724ce44b3c6fc37560af974072b346e45ac1a3b
    - name: quay.io/modh/kserve-agent@sha256:7c5557fe946eef95ea33ab9ddf5f88da62ee7a0af46348271549ab86ca351296
    - name: quay.io/modh/kserve-controller@sha256:78bc9b598642a679818e347f389b65960917965086a7cac3de08f620f2b70536
    - name: quay.io/modh/kserve-router@sha256:5e8e14e885535d0318c687a85b125ffc7b8eb14e3e95fdb8e4eb3bfbb767d0b0
    - name: quay.io/modh/kserve-storage-initializer@sha256:8b3c5b7388dc75f64e82b4dfdc1b881e7e169a50a4be6a08a1b49cbbf92ca749
    - name: quay.io/modh/odh-anaconda-notebook@sha256:380c07bf79f5ec7d22441cde276c50b5eb2a459485cde05087837639a566ae3d
    - name: quay.io/modh/odh-generic-data-science-notebook@sha256:465e81c69c891565b979668b84adcf0c645b1ed99e1bf107474ef6bb56090027
    - name: quay.io/modh/odh-generic-data-science-notebook@sha256:76e6af79c601a323f75a58e7005de0beac66b8cccc3d2b67efb6d11d85f0cfa1
    - name: quay.io/modh/odh-generic-data-science-notebook@sha256:bb33abc67af1328d3b32899f58bcdc0cf1681605e1b5da57f8fe8da81523a9bd
    - name: quay.io/modh/odh-generic-data-science-notebook@sha256:e2cab24ebe935d87f7596418772f5a97ce6a2e747ba0c1fd4cec08a728e99403
    - name: quay.io/modh/odh-habana-notebooks@sha256:213e49f1aed8a36b86373f2cf15a6a854b9393684a5f3073195a7896d6b91365
    - name: quay.io/modh/odh-habana-notebooks@sha256:30bedcd9b007d087ec06b272b54ce552572e922f08810537def8724f98a1d541
    - name: quay.io/modh/odh-minimal-notebook-container@sha256:07d509dc2aa166e21e8b9ef2cd88d0863140fe4bf2169be2c4be44a62aa5d097
    - name: quay.io/modh/odh-minimal-notebook-container@sha256:39068767eebdf3a127fe8857fbdaca0832cdfef69eed6ec3ff6ed1858029420f
    - name: quay.io/modh/odh-minimal-notebook-container@sha256:eec50e5518176d5a31da739596a7ddae032d73851f9107846a587442ebd10a82
    - name: quay.io/modh/odh-minimal-notebook-container@sha256:f224d87854de9b8879022cf47b432cc9a4777f9d164b8341c20d0046c0182194
    - name: quay.io/modh/odh-pytorch-notebook@sha256:4d947ed12e72f77084a789c70fc6bda5898356332ecc0b044be9599aff57eec1
    - name: quay.io/modh/odh-pytorch-notebook@sha256:97b346197e6fc568c2eb52cb82e13a206277f27c21e299d1c211997f140f638b
    - name: quay.io/modh/odh-pytorch-notebook@sha256:b68e0192abf7d46c8c6876d0819b66c6a2d4a1e674f8893f8a71ffdcba96866c
    - name: quay.io/modh/odh-pytorch-notebook@sha256:cc9bd664e734467d74f8a3b5cb2d603e5b488620addf30fb67cebfa654ed41a9
    - name: quay.io/modh/odh-trustyai-notebook@sha256:0d09325fd35dafbc2b202a7aafa03ab67d1730545f63fecbea43564f6214bf41
    - name: quay.io/modh/odh-trustyai-notebook@sha256:8c5e653f6bc6a2050565cf92f397991fbec952dc05cdfea74b65b8fd3047c9d4
    - name: quay.io/modh/odh-trustyai-notebook@sha256:a2aaaf40fffcfa890e21baac0559325dd82a661d38e3a4626a62b3609ef45ff9
    - name: quay.io/modh/openvino_model_server@sha256:9ccb29967f39b5003cf395cc686a443d288869578db15d0d37ed8ebbeba19375
    - name: quay.io/modh/runtime-images@sha256:0a3c137492e66c5fac89786f90dbbfdfd3eecd8d9c0e4e890aeeb8f558cd731d
    - name: quay.io/modh/runtime-images@sha256:1711dfaeb5fea393ebe09dc957fcf36720ff2859c3afc47fe4e2110b68bc918f
    - name: quay.io/modh/runtime-images@sha256:28f28de1b5f3d9e1f75ccf69604003f2366e0b9e138b8eb98212110f40195b77
    - name: quay.io/modh/runtime-images@sha256:54cc74e9dc65c51c839fde9c25c23378c5157fee0ce85b1b61623b9c9563da98
    - name: quay.io/modh/runtime-images@sha256:90e394f5a379c24176b1efee6c84b83866314cafd539a66cd58544f24def84f9
    - name: quay.io/modh/runtime-images@sha256:abd44461b3d9309ed5517aa4e9e124652ff8df255c4d481b9d3d37841c36e4ac
    - name: quay.io/modh/runtime-images@sha256:e750b6b183ad987be1f7bfb6b814e36d0a79e393a3d66d0294686f14dfea1644
    - name: quay.io/modh/runtime-images@sha256:e802af94ca7daf747bf0af27aa5b66745b2f07e0a2c3d9437036bffa84a256b4
    - name: quay.io/modh/text-generation-inference@sha256:294f07b2a94a223a18e559d497a79cac53bf7893f36cfc6c995475b6e431bcfe
    - name: quay.io/modh/vllm@sha256:e14cae9114044dc9fe71e99c3db692a892b2caffe04283067129ab1093a7bde5
    - name: quay.io/modh/caikit-tgis-serving@sha256:4e907ce35a3767f5be2f3175a1854e8d4456c43b78cf3df4305bceabcbf0d6e2
    - name: quay.io/modh/caikit-nlp@sha256:0cde6c26e02ec398aea959a1a1bcdc615b86821adb41989e81d03de01124545c
    - name: quay.io/modh/text-generation-inference@sha256:294f07b2a94a223a18e559d497a79cac53bf7893f36cfc6c995475b6e431bcfe
    - name: quay.io/modh/openvino_model_server@sha256:9ccb29967f39b5003cf395cc686a443d288869578db15d0d37ed8ebbeba19375
    - name: quay.io/modh/vllm@sha256:e14cae9114044dc9fe71e99c3db692a892b2caffe04283067129ab1093a7bde5
    - name: quay.io/modh/fms-hf-tuning@sha256:4ab6b17d9ef74c092fe8ff24b505ecad41a7d231c470bc4ee0cee23080976b08
    - name: quay.io/rhoai/ray@sha256:859f5c41d41bad1935bce455ad3732dff9d4d4c342b7155a7cd23809e85698ab
    - name: quay.io/modh/must-gather@sha256:a57ac193de3a7e258d22eda528c598ef6ffe52725b09f226e0cc948b3b75bfb3

  helm: {}

```

The list of images and hashes will vary from version to version of the AI operator.

### Sync the data

Once the oc-mirror process has finished, you can sync the data to the high side for loading into your image registry

```rsync -avP /mnt/low-side-data/ highside:/mnt/high-side-data/```

Once the rsync process finishes, you can load the images to the destination. Note this command may be different
depending on your architecture.

```oc-mirror --from=/mnt/high-side-data/mirror_seq1_000000.tar docker://$(hostname):8443```

### Set up OCP for the mirrored operator index

Disable the default OperaterHub locations - these won't work since the cluster can't reach out to them.

```
oc patch OperatorHub cluster --type json     -p '[{"op": "add", "path": "/spec/disableAllDefaultSources", "value": true}]'
```

oc mirror will generate an operator index, for example


```
$ cat catalogSource-cs-redhat-operator-index.yaml 
```
```yaml 
apiVersion: operators.coreos.com/v1alpha1
kind: CatalogSource
metadata:
  name: cs-redhat-operator-index
  namespace: openshift-marketplace
spec:
  image: ip-10-0-54-104.us-east-2.compute.internal:8443/redhat/redhat-operator-index:v4.14
  sourceType: grpc
```


### Configure OCP to pull from the mirror

Red Hat OCP has a concept called "Image Source Content Policy" (ISCP), "Image Digest Mirror Sets" (IDMS) and "Image Tag Mirror Sets" (ITMS).

`oc-mirror` (v1) will generate an ISCP. However, ISCP is being deprecated in favor of IDMS and ITMS.  The difference between an IDMS and ITMS
is simply one will redirect only for digests (IDMS) and the other only for tags (ITMS).  The deprecated ISCP will only do digests.

To convert the generated ISCP, you can run `oc adm migrate iscp`

Example output:
```
---
  apiVersion: config.openshift.io/v1
  kind: ImageDigestMirrorSet
  metadata:
    name: generic-0
  spec:
    imageDigestMirrors:
    - mirrorSourcePolicy: NeverContactSource
      mirrors:
      - ip-10-0-54-104.us-east-2.compute.internal:8443/openshift4
      source: registry.redhat.io/openshift4
    - mirrorSourcePolicy: NeverContactSource
      mirrors:
      - ip-10-0-54-104.us-east-2.compute.internal:8443/modh
      source: quay.io/modh
    - mirrorSourcePolicy: NeverContactSource
      mirrors:
      - ip-10-0-54-104.us-east-2.compute.internal:8443/rhoai
      source: quay.io/rhoai
    - mirrorSourcePolicy: NeverContactSource
      mirrors:
      - ip-10-0-54-104.us-east-2.compute.internal:8443/rhel8
      source: registry.redhat.io/rhel8
    - mirrorSourcePolicy: NeverContactSource
      mirrors:
      - ip-10-0-54-104.us-east-2.compute.internal:8443/integreatly
      source: quay.io/integreatly
---
  apiVersion: config.openshift.io/v1
  kind: ImageDigestMirrorSet
  metadata:
    labels:
      operators.openshift.org/catalog: "true"
    name: operator-0
  spec:
    imageDigestMirrors:
    - mirrorSourcePolicy: NeverContactSource
      mirrors:
      - ip-10-0-54-104.us-east-2.compute.internal:8443/rh-sso-7
      source: registry.redhat.io/rh-sso-7
    - mirrorSourcePolicy: NeverContactSource
      mirrors:
      - ip-10-0-54-104.us-east-2.compute.internal:8443/rhel8
      source: registry.redhat.io/rhel8
    - mirrorSourcePolicy: NeverContactSource
      mirrors:
      - ip-10-0-54-104.us-east-2.compute.internal:8443/source-to-image
      source: registry.redhat.io/source-to-image
    - mirrorSourcePolicy: NeverContactSource
      mirrors:
      - ip-10-0-54-104.us-east-2.compute.internal:8443/rhel7
      source: registry.redhat.io/rhel7
    - mirrorSourcePolicy: NeverContactSource
      mirrors:
      - ip-10-0-54-104.us-east-2.compute.internal:8443/rhoai
      source: registry.redhat.io/rhoai
    - mirrorSourcePolicy: NeverContactSource
      mirrors:
      - ip-10-0-54-104.us-east-2.compute.internal:8443/openshift4
      source: registry.redhat.io/openshift4
    - mirrorSourcePolicy: NeverContactSource
      mirrors:
      - ip-10-0-54-104.us-east-2.compute.internal:8443/openshift-pipelines
      source: registry.redhat.io/openshift-pipelines
    - mirrorSourcePolicy: NeverContactSource
      mirrors:
      - ip-10-0-54-104.us-east-2.compute.internal:8443/3scale-tech-preview
      source: registry.redhat.io/3scale-tech-preview
    - mirrorSourcePolicy: NeverContactSource
      mirrors:
      - ip-10-0-54-104.us-east-2.compute.internal:8443/openshift-serverless-1-tech-preview
      source: registry.redhat.io/openshift-serverless-1-tech-preview
    - mirrorSourcePolicy: NeverContactSource
      mirrors:
      - ip-10-0-54-104.us-east-2.compute.internal:8443/ubi8-minimal
      source: registry.redhat.io/ubi8-minimal
    - mirrorSourcePolicy: NeverContactSource
      mirrors:
      - ip-10-0-54-104.us-east-2.compute.internal:8443/openshift-serverless-1
      source: registry.redhat.io/openshift-serverless-1
    - mirrorSourcePolicy: NeverContactSource
      mirrors:
      - ip-10-0-54-104.us-east-2.compute.internal:8443/web-terminal
      source: registry.redhat.io/web-terminal
    - mirrorSourcePolicy: NeverContactSource
      mirrors:
      - ip-10-0-54-104.us-east-2.compute.internal:8443/openshift-gitops-1
      source: registry.redhat.io/openshift-gitops-1
    - mirrorSourcePolicy: NeverContactSource
      mirrors:
      - ip-10-0-54-104.us-east-2.compute.internal:8443/ubi8
      source: registry.redhat.io/ubi8
    - mirrorSourcePolicy: NeverContactSource
      mirrors:
      - ip-10-0-54-104.us-east-2.compute.internal:8443/devworkspace
      source: registry.redhat.io/devworkspace
    - mirrorSourcePolicy: NeverContactSource
      mirrors:
      - ip-10-0-54-104.us-east-2.compute.internal:8443/ubi9
      source: registry.redhat.io/ubi9
    - mirrorSourcePolicy: NeverContactSource
      mirrors:
      - ip-10-0-54-104.us-east-2.compute.internal:8443/openshift-service-mesh
      source: registry.redhat.io/openshift-service-mesh
---
  apiVersion: config.openshift.io/v1
  kind: ImageDigestMirrorSet
  metadata:
    name: release-0
  spec:
    imageDigestMirrors:
    - mirrorSourcePolicy: NeverContactSource
      mirrors:
      - ip-10-0-54-104.us-east-2.compute.internal:8443/openshift/release
      source: quay.io/openshift-release-dev/ocp-v4.0-art-dev
    - mirrorSourcePolicy: NeverContactSource
      mirrors:
      - ip-10-0-54-104.us-east-2.compute.internal:8443/openshift/release-images
      source: quay.io/openshift-release-dev/ocp-release
```

You'll need to create an ITMS for anything that gets pulled by tag.  For example:

```
apiVersion: config.openshift.io/v1
kind: ImageTagMirrorSet
metadata:
  name: generic-0
spec:
  imageTagMirrors:
  - mirrorSourcePolicy: NeverContactSource
    mirrors:
    - ip-10-0-54-104.us-east-2.compute.internal:8443/openshift4
    source: registry.redhat.io/openshift4
  - mirrorSourcePolicy: NeverContactSource
    mirrors:
    - ip-10-0-54-104.us-east-2.compute.internal:8443/gogs
    source: registry-1.docker.io/v2/gogs
  - mirrorSourcePolicy: NeverContactSource
    mirrors:
    - ip-10-0-54-104.us-east-2.compute.internal:8443/rhpds
    source: quay.io/rhpds
  - mirrorSourcePolicy: NeverContactSource
    mirrors:
    - ip-10-0-54-104.us-east-2.compute.internal:8443/kubebuilder
    source: gcr.io/kubebuilder
  - mirrorSourcePolicy: NeverContactSource
    mirrors:
    - ip-10-0-54-104.us-east-2.compute.internal:8443/rhel8
    source: registry.redhat.io/rhel8
  - mirrorSourcePolicy: NeverContactSource
    mirrors:
    - ip-10-0-54-104.us-east-2.compute.internal:8443/minio
    source: quay.io/minio
```

The ai-accelerator uses Red Hat GitOps (ArgoCD) to define what to install.  As such, you'll need a git repo that 
ArgoCD can dial out to.  For this Proof of Concept, we utilized Gitea as described by RHPDS - [Gitea Operator](https://github.com/rhpds/gitea-operator)
### Certificate Issue

You may see below certificate error while downloading models from model storage or external storage. This error comes when the certificates to be trusted are missing from cluster wide certificate authority bundle.

```

2024-10-01714:55:39Z
Failed to pull model from storage
{"model_id": "fraud_", "error": "rc
error:
code = Unknown desc = Failed to pull model from storage due to error: unable to list objects in bucket
'my-storage': RequestError: send request failedincaused by: Get \"htts://xxxxxxx\": *509: certificate signed by unknown authority"}

```

Please follow the below steps to fix the issue

```
$ oc get secret -n openshift-ingress-operator router-ca -o jsonpath='{.data.tls\.crt}' | base64 -d > openshift-ca-bundle.pem
$ oc get configmap -n openshift-config openshift-service-ca.crt -o jsonpath='{.data.service-ca\.crt}' >> openshift-ca-bundle.pem
$ CA_BUNDLE_FILE=./openshift-ca-bundle.pem
$ oc patch dscinitialization default-dsci --type='json' -p='[{"op":"replace","path":"/spec/trustedCABundle/customCABundle","value":"'"$(awk '{printf "%s\\n", $0}' $CA_BUNDLE_FILE)"'"}]'

```
For more information see below link

https://docs.redhat.com/en/documentation/red_hat_openshift_ai_self-managed/2.13/html/installing_and_uninstalling_openshift_ai_self-managed/working-with-certificates_certs
