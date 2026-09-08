#!/usr/bin/env bash
set -euo pipefail

GATEWAY_NS="${GATEWAY_NS:-openshift-ingress}"
GATEWAY_NAME="${GATEWAY_NAME:-maas-default-gateway}"
ROUTE_NAME="${ROUTE_NAME:-maas-gateway-route}"

resolve_route_host() {
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
}

patch_route_host() {
  CURRENT_HOST=$(oc get route "${ROUTE_NAME}" -n "${GATEWAY_NS}" -o=jsonpath='{.spec.host}')
  if [ "${CURRENT_HOST}" = "${ROUTE_HOST}" ]; then
    echo "Route host is already set to ${ROUTE_HOST}"
    return 0
  fi

  echo "Patching route/${ROUTE_NAME} in ${GATEWAY_NS}"
  oc patch route "${ROUTE_NAME}" -n "${GATEWAY_NS}" \
    --type=merge \
    -p "{\"spec\":{\"host\":\"${ROUTE_HOST}\"}}"
}

patch_gateway_hostname() {
  local listener_count index current_hostname listener_name op patch_ops="" needs_patch=0
  local listener_names="" patch_listener_names=""

  listener_count=$(oc get gateway "${GATEWAY_NAME}" -n "${GATEWAY_NS}" \
    -o go-template='{{len .spec.listeners}}')

  if [ "${listener_count}" -eq 0 ]; then
    echo "No listeners found on gateway/${GATEWAY_NAME}"
    return 1
  fi

  for ((index=0; index<listener_count; index++)); do
    listener_name=$(oc get gateway "${GATEWAY_NAME}" -n "${GATEWAY_NS}" \
      -o jsonpath="{.spec.listeners[${index}].name}")
    current_hostname=$(oc get gateway "${GATEWAY_NAME}" -n "${GATEWAY_NS}" \
      -o jsonpath="{.spec.listeners[${index}].hostname}")

    if [ "${current_hostname}" = "${ROUTE_HOST}" ]; then
      continue
    fi

    needs_patch=1
    if [ -n "${current_hostname}" ]; then
      op="replace"
    else
      op="add"
    fi

    if [ -n "${patch_ops}" ]; then
      patch_ops+=","
    fi
    patch_ops+="{\"op\":\"${op}\",\"path\":\"/spec/listeners/${index}/hostname\",\"value\":\"${ROUTE_HOST}\"}"
  done

  if [ "${needs_patch}" -eq 0 ]; then
    echo "Gateway listener ${listener_name} hostnames are already set to ${ROUTE_HOST} "
    return 0
  fi

  echo "Patching gateway/${GATEWAY_NAME} listener ${listener_name} hostname in ${GATEWAY_NS}"
  oc patch gateway "${GATEWAY_NAME}" -n "${GATEWAY_NS}" --type=json -p="[${patch_ops}]"
}

resolve_route_host
patch_route_host
patch_gateway_hostname
