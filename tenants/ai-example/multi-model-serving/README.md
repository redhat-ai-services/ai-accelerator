# Multi Model Serving

The Fraud Detection ONNX model is being used for this example. Link to the Credit Fraud Detection Demo in References section.

The Inference Service references the Serving Runtime / Model Server using `runtime: multi-model-server` in the `spec:`.

Minio will be created in the namespace, as well as the minio login secret and the `multi-model`. The Multi Model server will be created using the `serving-runtime.yaml` and the model will be deployed into the server using the `inference-service.yaml`.

NOTE: For the deployed model, the inference route is character limited. If the route does not come up, check to make sure the name/url is less than 63 characters for it to be created.

## Testing

When creating workbench to run tests - make sure to use 'Standard Data Science' 2024.2 image.

Test notebook using REST connectivity requires infer_url value updated to use correct location from fraud-detection-model OpenShift route.

### References:
https://github.com/red-hat-data-services/credit-fraud-detection-demo
