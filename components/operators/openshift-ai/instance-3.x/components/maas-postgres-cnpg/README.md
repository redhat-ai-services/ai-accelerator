# maas-postgres-cnpg

## Purpose

This component provisions a PostgreSQL database for [Models-as-a-Service (MaaS)](https://docs.redhat.com/en/documentation/red_hat_openshift_ai_self-managed/3.4/html/govern_llm_access_with_models-as-a-service/deploy-and-manage-models-as-a-service_maas) using the [CloudNativePG](https://cloudnative-pg.io/) operator.

OpenShift AI 3.4 and later requires an external PostgreSQL 14+ instance to store MaaS subscription, API key, and usage data. OpenShift AI does not provide this database; you must provision and manage it yourself. This component automates that provisioning on-cluster and creates the `maas-db-config` secret that MaaS expects.

This component includes:

- The `maas-db` namespace
- A CloudNativePG `Cluster` named `openshift-ai-maas` with database and role `maas`
- A cert-manager `Certificate` for PostgreSQL TLS
- A Job that creates the `maas-db-config` secret in the `redhat-ods-applications` namespace with the `DB_CONNECTION_URL` connection string

For the manual procedure and secret format, see [Configure the database secret for Models-as-a-Service](https://docs.redhat.com/en/documentation/red_hat_openshift_ai_self-managed/3.4/html/govern_llm_access_with_models-as-a-service/deploy-and-manage-models-as-a-service_maas#configure-the-database-secret-for-models-as-a-service).

## Prerequisites

- Red Hat OpenShift AI 3.4 or later with MaaS enabled (`spec.components.kserve.modelsAsService.managementState: Managed` in the `DataScienceCluster`)
- The CloudNativePG operator installed and available in the cluster
- cert-manager installed with a `ClusterIssuer` named `ca-issuer`
- A default or configured `StorageClass` for the PostgreSQL persistent volume (the cluster defaults to `gp3-csi`)

## Usage

Add this component to your overlay `kustomization.yaml`:

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

## Verification

Confirm the PostgreSQL cluster is ready:

```shell
oc get cluster openshift-ai-maas -n maas-db
```

Confirm the MaaS database secret exists:

```shell
oc get secret maas-db-config -n redhat-ods-applications
```

Expected output:

```plaintext
NAME             TYPE     DATA   AGE
maas-db-config   Opaque   1      5s
```

## Customization

- Adjust cluster size, resources, or storage in [pg-cluster.yaml](./pg-cluster.yaml)
- Update TLS certificate DNS names or issuer in [certs.yaml](./certs.yaml)
- Modify the secret creation Job, RBAC, or connection string logic under [maas-postgres-secret/](./maas-postgres-secret/)
