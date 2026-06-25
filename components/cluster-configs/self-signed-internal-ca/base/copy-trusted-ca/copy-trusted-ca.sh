#!/usr/bin/env bash
set -euo pipefail

SOURCE_SECRET_NAMESPACE="${SOURCE_SECRET_NAMESPACE:-cert-manager}"
SOURCE_SECRET_NAME="${SOURCE_SECRET_NAME:-cert-manager-ca}"
SOURCE_SECRET_KEY="${SOURCE_SECRET_KEY:-tls.crt}"
TARGET_CONFIGMAP_NAMESPACE="${TARGET_CONFIGMAP_NAMESPACE:-openshift-config}"
TARGET_CONFIGMAP_NAME="${TARGET_CONFIGMAP_NAME:-selfsigned-ca-bundle}"
TARGET_CONFIGMAP_KEY="${TARGET_CONFIGMAP_KEY:-ca-bundle.crt}"

source_secret_key_jsonpath="${SOURCE_SECRET_KEY//./\\.}"
target_configmap_key_jsonpath="${TARGET_CONFIGMAP_KEY//./\\.}"

copy_trusted_ca() {
  local tmp_ca tmp_current
  tmp_ca=$(mktemp)
  trap 'rm -f "${tmp_ca}" "${tmp_current:-}"' RETURN

  echo "Reading ${SOURCE_SECRET_KEY} from secret ${SOURCE_SECRET_NAME} in namespace ${SOURCE_SECRET_NAMESPACE}"
  oc get secret "${SOURCE_SECRET_NAME}" -n "${SOURCE_SECRET_NAMESPACE}" \
    -o "jsonpath={.data.${source_secret_key_jsonpath}}" | base64 -d > "${tmp_ca}"

  if [ ! -s "${tmp_ca}" ]; then
    echo "Secret ${SOURCE_SECRET_NAME} does not contain a ${SOURCE_SECRET_KEY} value" >&2
    return 1
  fi

  if oc get configmap "${TARGET_CONFIGMAP_NAME}" -n "${TARGET_CONFIGMAP_NAMESPACE}" >/dev/null 2>&1; then
    tmp_current=$(mktemp)
    oc get configmap "${TARGET_CONFIGMAP_NAME}" -n "${TARGET_CONFIGMAP_NAMESPACE}" \
      -o "jsonpath={.data.${target_configmap_key_jsonpath}}" > "${tmp_current}"
    if cmp -s "${tmp_ca}" "${tmp_current}"; then
      echo "ConfigMap ${TARGET_CONFIGMAP_NAME} already contains the expected ${TARGET_CONFIGMAP_KEY} content"
      return 0
    fi
  fi

  echo "Creating or updating ConfigMap ${TARGET_CONFIGMAP_NAME} in namespace ${TARGET_CONFIGMAP_NAMESPACE}"
  oc create configmap "${TARGET_CONFIGMAP_NAME}" \
    --from-file="${TARGET_CONFIGMAP_KEY}=${tmp_ca}" \
    -n "${TARGET_CONFIGMAP_NAMESPACE}" \
    --dry-run=client -o yaml | oc apply -f -
}

copy_trusted_ca
