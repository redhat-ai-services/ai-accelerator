Service Account is being created because we need to read secrets from the minio namespace. It has a _ClusterRoleBinding_ with the _Edit_ Role.

Create DS-Connections Job:
Creates a job that will go into `ai-example-training` namespace and grabs (using the `demo-setup` service account) the admin and password for minio from the secret that was created for minio. Grabs the API route.


Create Bucket Job:
Need to create service account and role binding to read the ds-connection secret. The ds-connection secret has the minio url and minio user and password. The job grabs the information from the secret, then uses it to log into the minio s3 and create a bucket.

References:
https://rh-aiservices-bu.github.io/fraud-detection/fraud-detection-workshop/running-a-script-to-install-storage.html
https://raw.githubusercontent.com/rh-aiservices-bu/fraud-detection/main/setup/setup-s3-no-sa.yaml
