# Create and Run a RHOAI Data Science Pipeline

In order to get RHOAI Data Science Pipelines to work, we need to have OpenShift Pipelines and RHOAI operators installed.
We also need an S3 storage bucket. In this tutorial, the operators should be already be installed.

### Setting up and using Minio.
 1. Create `minio` namespace or use whatever namespace you would like.
 2. Change to new namespace
 3. Apply the _minio.yaml_ file.
    This will create the PVC, admin password secret, deployment, service, api route, and UI route.
 4. The credentials to log into minio are from the secret `minio-secret` from the minio.yaml to login. `minio:minio123`
 5. Create new Data Science Project or apply the `ds-sample-project-ns.yaml`. This will create a new Data Science Project named: `datascience-sample-project`
 6. In the RHOAI Dashboard, configure a new pipeline server. Or you can apply the `pipeline-server.yaml`. (make sure the namespace is correct.)
    Enter the S3 information. Access key is `minio`. Secret key is `minio123`. Endpoint is the minio API endpoint. Bucket: you can create a new bucket on the `minio-ui` or if left blank, it will create a new bucket in S3.
 7. Import a new pipeline. Example: `cointoss.yaml`
 8. After importing a new pipeline, press the 3 kebab menu and create run. Give the run a name and create.
 9. The pipeline will now run. You can go into OpenShift Dashboard>Pipelines>Pipeline Runs to see more details about the pipeline run.