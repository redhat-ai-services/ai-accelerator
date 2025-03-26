#!/usr/bin/env bash
set -e

# Wait for trustyai-service-operator-controller-manager Deployment to become available
echo "Waiting for trustyai-service-operator-controller-manager Deployment to become avaiable"
oc wait --for=condition=Available=true deployment/trustyai-service-operator-controller-manager -n redhat-ods-applications

# Patch configmap
echo "Patching trustyai-service-operator-config ConfigMap to allow online connectivity"
oc patch configmap trustyai-service-operator-config -n redhat-ods-applications \
--type merge -p '{"data":{"lmes-allow-online":"true","lmes-allow-code-execution":"true"}}'

# Restart trustyai-service-operator-controller-manager Deployment
echo "Restarting trustyai-service-operator-controller-manager Deployment"
oc rollout restart deployment trustyai-service-operator-controller-manager -n redhat-ods-applications
