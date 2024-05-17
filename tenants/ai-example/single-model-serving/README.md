# Single Serving Model Example

### Folder Structure:
```sh
tenants/
└── ai-example
    ├── single-model-serving
        ├── base
        ├── examples
        │   ├── tgis-flan-single-model-server
        │   └── vllm-granite-single-model-server
        └── overlays
            ├── rhoai-'nonGPU'
            └── rhoai-'GPU'
```
If using __nonGPU__ cluster, use the `rhoai-'nonGPU'` overlay. It will use the ___flan-t5-small___ example which uses CPU.

If using __GPU__ cluster, use the `rhoai-'GPU'` overlay. It will use the ___granite-3b-code-base___ example which utilizes GPU.

In the ___overlays___ folder, Kustomize will create the instances for minio in the namespace.
Kustomize will take care of adding the namespace to the manifests.

The python scripts used for the jobs, will be put in a ConfigMap and will be called by the job. Kustomize takes care of putting the scripts in a ConfigMap.

### For CPU model:

__Model:__ flan-t5-small from https://huggingface.co/google/flan-t5-small
__ServingRuntime:__ TGIS Standalone ServingRuntime for KServe (default serving runtime with RHOAI 2.9)

### For GPU model:
__Model:__ granite-3b-code-base from https://huggingface.co/ibm-granite/granite-3b-code-base
__ServingRuntime:__ vLLM from: https://github.com/rh-aiservices-bu/llm-on-openshift/blob/main/serving-runtimes/vllm_runtime/vllm-runtime.yaml

NOTE: For the ServingRuntime, make sure your model has the correct ___model embeddings length___. In the __vLLM ServingRuntime manifest__, the default is `--max-model-len -"6144"`, you can change this in the vLLM ServingRuntime __args section__ to match your model.
The __granite-3b-code-base model__ has `"max_position_embeddings": 2048,` (found in the [config.json](https://huggingface.co/ibm-granite/granite-3b-code-base/blob/main/config.json) of the project directory)


### Upload Model to S3 Job:
This job uses Git to pull a project which has the model, then will upload the files to minio S3 storage. It uses the minio credentials (that was created by the `create-ds-connection-secret.yaml`) to upload the files (pulled from external) into the minio bucket that has already been created. It uses 3 containers: ___wait-for-minio___ which waits for the login credentials to be preset; ___git-cloner___ which uses Git to clone the project; and ___upload-model-to-s3___ which uploads the recently cloned files to minio S3.

Be sure to check the __env variables__ of the containers for the path and model.

### Create DS-Connections Job:
This job, (using the `demo-setup` service account), will go into `ai-example-training` namespace and will grab the admin and password for minio from the secret that was created for minio. It also grabs the API route, bucket name, and region info.

NOTE: aws_s3_url example: https://minio-api-ai-example-training.apps.cluster-dlsw9.dlsw9.sandbox2226.opentlc.com

### Create Bucket Job:
This job will wait for the minio credentials and will then create a bucket in minio. Bucket name can be found in the __ENV__ section of the manifest named __`BUCKETNAME`__.

### Service Account:
A Service Account is being created because we need to read secrets from the minio namespace. It has a ___ClusterRoleBinding___ with the ___Edit___ Role.


Testing the model can be found in the test-model folder.

#### References:
- https://github.com/rh-aiservices-bu/test-drive/tree/main/llm
- https://rh-aiservices-bu.github.io/fraud-detection/fraud-detection-workshop/running-a-script-to-install-storage.html
- https://raw.githubusercontent.com/rh-aiservices-bu/fraud-detection/main/setup/setup-s3-no-sa.yaml
- https://github.com/rh-aiservices-bu/llm-on-openshift/blob/main/serving-runtimes/vllm_runtime/vllm-runtime.yaml
