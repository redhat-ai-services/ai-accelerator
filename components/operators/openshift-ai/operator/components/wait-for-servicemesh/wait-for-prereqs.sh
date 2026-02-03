#!/usr/bin/env bash
set -e

TIMEOUT_SECONDS=60

wait_for_service_mesh(){
  echo "Checking status of all pre-reqs"
  PREREQ_RESOURCES=(
    crd/istios.sailoperator.io:condition=established
    crd/crd/kuadrants.kuadrant.io:condition=established
  )

  for field in "${PREREQ_RESOURCES[@]}"
  do
    RESOURCE=$(echo "$field" | cut -d ":" -f 1)
    CONDITION=$(echo "$field" | cut -d ":" -f 2)

    echo "Waiting for ${RESOURCE} state to be ${CONDITION}..."
    oc wait --for="${CONDITION}" "${RESOURCE}" --timeout="${TIMEOUT_SECONDS}s"

  done

  sleep 60
}

wait_for_service_mesh
