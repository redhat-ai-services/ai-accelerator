#!/usr/bin/env bash

patch_route_host() {
  CONSOLE_URL=$(oc whoami --show-console)
  if [ -z "${CONSOLE_URL}" ]; then
    echo "Failed to retrieve console URL from oc whoami --show-console"
    return 1
  fi

  CONSOLE_HOST=${CONSOLE_URL#https://}
  CONSOLE_HOST=${CONSOLE_HOST#http://}
  CLUSTER_URL=${CONSOLE_HOST#*.apps.}

  if [ -z "${CLUSTER_URL}" ] || [ "${CLUSTER_URL}" = "${CONSOLE_HOST}" ]; then
    echo "Failed to extract cluster URL from console URL: ${CONSOLE_URL}"
    return 1
  fi

  ROUTE_HOST="maas.apps.${CLUSTER_URL}"
  echo "Target route host: ${ROUTE_HOST}"

  CURRENT_HOST=$(oc get route maas-gateway-route -n openshift-ingress -o=jsonpath='{.spec.host}')
  if [ "${CURRENT_HOST}" = "${ROUTE_HOST}" ]; then
    echo "Route host is already set to ${ROUTE_HOST}"
    return 0
  fi

  echo "Patching maas-gateway-route in openshift-ingress"
  oc patch route maas-gateway-route -n openshift-ingress \
    --type=merge \
    -p "{\"spec\":{\"host\":\"${ROUTE_HOST}\"}}"
}

patch_route_host
