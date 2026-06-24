# External Secrets Operator for Red Hat OpenShift

Install the [External Secrets Operator for Red Hat OpenShift](https://docs.redhat.com/en/documentation/openshift_container_platform/latest/html/security_and_compliance/external-secrets-operator-for-red-hat-openshift). This operator deploys and manages the `external-secrets` controller, which integrates with external secret management systems such as AWS Secrets Manager, Azure Key Vault, and HashiCorp Vault.

Use it to keep secrets out of Git while still managing them in a GitOps workflow. After installation, create a `SecretStore` or `ClusterSecretStore` to connect to your provider, then create `ExternalSecret` resources to sync values into native Kubernetes `Secret` objects.

This component is structured as:

- `operator/` — installs the operator subscription from `redhat-operators`
- `instance/` — creates the cluster-scoped `ExternalSecretsConfig` named `cluster` with egress network policies for the controller
- `aggregate/` — installs the operator and instance together

Do not use the `base` directories directly. Patch the subscription channel in an overlay that matches your OpenShift version.

The current overlays available are:

* [stable-v1](aggregate/overlays/stable-v1) — operator and instance
* [stable-v1](operator/overlays/stable-v1) — operator only
* [default](instance/overlays/default) — instance only

## Usage

Install the operator and instance together:

```
oc apply -k components/operators/openshift-external-secrets-operator/aggregate/overlays/stable-v1
```

Install the operator only:

```
oc apply -k components/operators/openshift-external-secrets-operator/operator/overlays/stable-v1
```

Install the instance only, after the operator is available:

```
oc apply -k components/operators/openshift-external-secrets-operator/instance/overlays/default
```

As part of a kustomization overlay in this repository:

```yaml
apiVersion: kustomize.config.k8s.io/v1beta1
kind: Kustomization

resources:
  - ../../../../components/operators/openshift-external-secrets-operator/aggregate/overlays/stable-v1
```

## Post-install configuration

The default instance overlay creates an `ExternalSecretsConfig` named `cluster` in the `external-secrets` namespace. This resource configures the managed operand, including network policies that allow the controller to reach external secret providers.

After the operator and instance are ready, configure access to your secret provider:

1. Create a `SecretStore` or `ClusterSecretStore` with provider credentials and connection details.
2. Create `ExternalSecret` resources that reference the store and define the target Kubernetes `Secret`.

For provider-specific examples and API details, see the [Red Hat OpenShift documentation](https://docs.redhat.com/en/documentation/openshift_container_platform/latest/html/security_and_compliance/external-secrets-operator-for-red-hat-openshift).
