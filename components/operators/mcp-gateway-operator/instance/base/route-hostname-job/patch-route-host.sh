#!/usr/bin/env bash
set -euo pipefail

GATEWAY_NS="${GATEWAY_NS:-mcp-gateway}"
GATEWAY_NAME="${GATEWAY_NAME:-mcp-gateway}"
ROUTE_NAME="${ROUTE_NAME:-mcp-gateway}"
LISTENER_NAME="${LISTENER_NAME:-mcp}"

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

  ROUTE_HOST="mcp.apps.${CLUSTER_URL}"
  echo "Target route host: ${ROUTE_HOST}"
}

patch_route_host() {
  CURRENT_HOST=$(oc get route "${ROUTE_NAME}" -n "${GATEWAY_NS}" -o=jsonpath='{.spec.host}')
  if [ "${CURRENT_HOST}" = "${ROUTE_HOST}" ]; then
    echo "Route host is already set to ${ROUTE_HOST}"
    return 0
  fi

  echo "Patching route/${ROUTE_NAME} in ${GATEWAY_NS} to host ${ROUTE_HOST}"
  oc patch route "${ROUTE_NAME}" -n "${GATEWAY_NS}" \
    --type=merge \
    -p "{\"spec\":{\"host\":\"${ROUTE_HOST}\"}}"
}

patch_gateway_hostname() {
  local listener_count index current_hostname listener_name op found=0

  listener_count=$(oc get gateway "${GATEWAY_NAME}" -n "${GATEWAY_NS}" \
    -o go-template='{{len .spec.listeners}}')

  if [ "${listener_count}" -eq 0 ]; then
    echo "No listeners found on gateway/${GATEWAY_NAME}"
    return 1
  fi

  for ((index=0; index<listener_count; index++)); do
    listener_name=$(oc get gateway "${GATEWAY_NAME}" -n "${GATEWAY_NS}" \
      -o jsonpath="{.spec.listeners[${index}].name}")

    # Only update the mcp listener; leave mcps (and any others) unchanged.
    if [ "${listener_name}" != "${LISTENER_NAME}" ]; then
      echo "Skipping gateway/${GATEWAY_NAME} listener ${listener_name}"
      continue
    fi

    found=1
    current_hostname=$(oc get gateway "${GATEWAY_NAME}" -n "${GATEWAY_NS}" \
      -o jsonpath="{.spec.listeners[${index}].hostname}")

    if [ "${current_hostname}" = "${ROUTE_HOST}" ]; then
      echo "Gateway listener ${LISTENER_NAME} hostname is already set to ${ROUTE_HOST}"
      return 0
    fi

    if [ -n "${current_hostname}" ]; then
      op="replace"
    else
      op="add"
    fi

    echo "Patching gateway/${GATEWAY_NAME} listener ${LISTENER_NAME} hostname to ${ROUTE_HOST}"
    oc patch gateway "${GATEWAY_NAME}" -n "${GATEWAY_NS}" --type=json \
      -p="[{\"op\":\"${op}\",\"path\":\"/spec/listeners/${index}/hostname\",\"value\":\"${ROUTE_HOST}\"}]"
    return 0
  done

  if [ "${found}" -eq 0 ]; then
    echo "Listener ${LISTENER_NAME} not found on gateway/${GATEWAY_NAME}"
    return 1
  fi
}

resolve_route_host
patch_route_host
patch_gateway_hostname
