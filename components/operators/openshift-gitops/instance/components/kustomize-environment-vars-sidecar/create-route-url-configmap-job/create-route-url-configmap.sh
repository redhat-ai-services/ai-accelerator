#!/bin/sh

set -e

echo "Attempting to get cluster app URL"
APP_URL=$(oc get ingresses.config/cluster -o jsonpath={.spec.domain})

echo
echo "App URL: ${APP_URL}"

CM_NAME="plugin-substitution-env-vars"
TARGET_NAMESPACE="openshift-gitops"

echo
echo "Checking if configmap ${CM_NAME} already exists"

if oc get configmap ${CM_NAME} -n ${TARGET_NAMESPACE} --ignore-not-found | grep ${CM_NAME}; then
    echo "Configmap ${CM_NAME} already exists. Skipping setup."
else
    echo "Creating ${CM_NAME} configmap"
    oc create configmap ${CM_NAME} --from-literal=SUB_DOMAIN=${APP_URL} -n ${TARGET_NAMESPACE}

    echo
    echo "Restarting repo server pod"
    sleep 10
    oc delete pods -l app.kubernetes.io/name=openshift-gitops-repo-server -n ${TARGET_NAMESPACE}
fi
