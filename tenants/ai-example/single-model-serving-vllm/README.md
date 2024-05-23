# Single Model Serving vLLM

__Model:__ granite-3b-code-base from https://huggingface.co/ibm-granite/granite-3b-code-base
__ServingRuntime:__ vLLM from: https://github.com/rh-aiservices-bu/llm-on-openshift/blob/main/serving-runtimes/vllm_runtime/vllm-runtime.yaml

NOTE: For the ServingRuntime, make sure your model has the correct ___model embeddings length___. In the __vLLM ServingRuntime manifest__, the default is `--max-model-len -"6144"`, you can change this in the vLLM ServingRuntime __args section__ to match your model.
The __granite-3b-code-base model__ has `"max_position_embeddings": 2048,` (found in the [config.json](https://huggingface.co/ibm-granite/granite-3b-code-base/blob/main/config.json) of the project directory)

On a fresh install and with updating the MachineSets to have GPUs, the vLLM deployment will timeout and error because the node (with GPUs) will not be ready by the time the vLLM starts up. Once the node with GPUs is ready, delete/redeploy the vLLM deployment so it will be scheduled on the correct node with GPUs.

#### References:
- https://github.com/rh-aiservices-bu/test-drive/tree/main/llm
- https://rh-aiservices-bu.github.io/fraud-detection/fraud-detection-workshop/running-a-script-to-install-storage.html
- https://raw.githubusercontent.com/rh-aiservices-bu/fraud-detection/main/setup/setup-s3-no-sa.yaml
- https://github.com/rh-aiservices-bu/llm-on-openshift/blob/main/serving-runtimes/vllm_runtime/vllm-runtime.yaml
