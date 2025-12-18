#!/usr/bin/env bash
set -e

TIMEOUT_SECONDS=60

wait_for_service_mesh(){
  echo "Checking status of all service_mesh pre-reqs"
  SERVICEMESH_RESOURCES=(
    crd/istio.sailoperator.io:condition=established
  )

  for field in "${SERVICEMESH_RESOURCES[@]}"
  do
    RESOURCE=$(echo "$field" | cut -d ":" -f 1)
    CONDITION=$(echo "$field" | cut -d ":" -f 2)

    echo "Waiting for ${RESOURCE} state to be ${CONDITION}..."
    oc wait --for="${CONDITION}" "${RESOURCE}" --timeout="${TIMEOUT_SECONDS}s"

  done
}

wait_for_service_mesh
