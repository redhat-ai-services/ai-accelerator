MODEL_ALPHA=demo-loan-nn-onnx-alpha
MODEL_BETA=demo-loan-nn-onnx-beta
TRUSTY_ROUTE=https://$(oc get route/trustyai-service --template={{.spec.host}})

for model in $MODEL_ALPHA $MODEL_BETA; do
  curl -sk  -H "Authorization: Bearer ${TOKEN}" -X POST --location $TRUSTY_ROUTE/info/names \
      -H "Content-Type: application/json" \
      -d "{
          \"modelId\": \"$model\",
          \"inputMapping\":
              {
                  \"customer_data_input-0\": \"Number of Children\",
                  \"customer_data_input-1\": \"Total Income\",
                  \"customer_data_input-2\": \"Number of Total Family Members\",
                  \"customer_data_input-3\": \"Is Male-Identifying?\",
                  \"customer_data_input-4\": \"Owns Car?\",
                  \"customer_data_input-5\": \"Owns Realty?\",
                  \"customer_data_input-6\": \"Is Partnered?\",
                  \"customer_data_input-7\": \"Is Employed?\",
                  \"customer_data_input-8\": \"Live with Parents?\",
                  \"customer_data_input-9\": \"Age\",
                  \"customer_data_input-10\": \"Length of Employment?\"
              },
          \"outputMapping\":
              {
                  \"predict\": \"Will Default?\"
              }
      }"
  echo
done
