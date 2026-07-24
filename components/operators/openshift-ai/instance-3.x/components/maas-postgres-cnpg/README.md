# maas-postgres-cnpg

## Purpose

This component provisions a PostgreSQL database for [Models-as-a-Service (MaaS)](https://docs.redhat.com/en/documentation/red_hat_openshift_ai_self-managed/3.4/html/govern_llm_access_with_models-as-a-service/deploy-and-manage-models-as-a-service_maas) and creates the `models-as-a-service-db-config` secret that MaaS expects.

OpenShift AI 3.4 and later requires an external PostgreSQL 14+ instance to store MaaS subscription, API key, and usage data. OpenShift AI does not provide this database; you must provision and manage it yourself. This component automates that provisioning on-cluster.

For the manual procedure and secret format, see [Configure the database secret for Models-as-a-Service](https://docs.redhat.com/en/documentation/red_hat_openshift_ai_self-managed/3.4/html/govern_llm_access_with_models-as-a-service/deploy-and-manage-models-as-a-service_maas#configure-the-database-secret-for-models-as-a-service).

## Dependencies

This component depends on two operators that must be installed and ready **before** you deploy it:

1. **[CloudNativePG](https://cloudnative-pg.io/)** — provisions and manages the PostgreSQL `Cluster` in `models-as-a-service-db`. Install from [components/operators/cloudnative-pg/operator/overlays/stable-v1](../../../../cloudnative-pg/operator/overlays/stable-v1).
2. **[External Secrets Operator for Red Hat OpenShift](https://docs.redhat.com/en/documentation/openshift_container_platform/latest/html/security_and_compliance/external-secrets-operator-for-red-hat-openshift)** — syncs the database connection string from the CloudNativePG-generated secret in `models-as-a-service-db` into the `models-as-a-service-db-config` secret in `redhat-ods-applications`. Install from [components/operators/openshift-external-secrets-operator/aggregate/overlays/stable-v1](../../../../openshift-external-secrets-operator/aggregate/overlays/stable-v1).

Without both operators running, the CloudNativePG `Cluster` and `ExternalSecret` resources in this component will not reconcile.

This component includes:

- The `models-as-a-service-db` namespace
- A CloudNativePG `Cluster` named `openshift-ai-maas` with database and role `maas`
- A cert-manager `Certificate` for PostgreSQL TLS
- A `SecretStore` and `ExternalSecret` that create `models-as-a-service-db-config` in `redhat-ods-applications` from the CloudNativePG application secret

## Prerequisites

- Red Hat OpenShift AI 3.4 or later with MaaS enabled (`spec.components.kserve.modelsAsService.managementState: Managed` in the `DataScienceCluster`)
- CloudNativePG operator installed and available in the cluster
- External Secrets Operator for Red Hat OpenShift installed and available in the cluster
- cert-manager installed with a `ClusterIssuer` named `ca-issuer`
- A default or configured `StorageClass` for the PostgreSQL persistent volume (the cluster defaults to `gp3-csi`)

## Usage

Install the dependent operators first, then add this component to your overlay `kustomization.yaml`:

```yaml
apiVersion: kustomize.config.k8s.io/v1beta1
kind: Kustomization

resources:
  - ../../base

components:
  - ../../components/maas-postgres-cnpg
  - ../../components/components-kserve-maas
```

Deploy the PostgreSQL database and secret before or alongside enabling MaaS. If `modelsAsService` is already `Managed` when the secret is created, restart the MaaS API deployment:

```shell
oc rollout restart deployment/maas-api -n redhat-ods-applications
```

## Customization

- Adjust cluster size, resources, or storage in [pg-cluster.yaml](./pg-cluster.yaml)
- Update TLS certificate DNS names or issuer in [certs.yaml](./certs.yaml)
- Modify the ExternalSecret, SecretStore, or RBAC under [maas-postgres-secret/](./maas-postgres-secret/)
