#!/bin/bash
set -e

source "$(dirname "$0")/functions.sh"

CLUSTERS_FOLDER="clusters/overlays/*"
GIT_PATCH_FILE="patch-application-repo-revision.yaml"
EXPECTED_REPO="https://github.com/redhat-ai-services/ai-accelerator.git"
EXPECTED_BRANCH="main"

DEBUG=false
GITHUB=true

ERROR_DETECTED=false

verifiy_patch_file() {
  if [ -z "$1" ]; then
    echo "No patch file supplied."
    exit 1
  else
    PATCH_FILE=$1
  fi

  if ${DEBUG}; then
    echo "Verifying if ${PATCH_FILE} exists"
  fi

  if [ ! -f "${PATCH_FILE}" ]; then
    echo "${PATCH_FILE} was not found."
    ERROR_DETECTED=true
  fi
}

verify_branch() {
  if [ -z "$1" ]; then
    echo "No patch file supplied."
    exit 1
  else
    PATCH_FILE=$1
  fi

  if [ -z "$2" ]; then
    echo "No expected branch supplied."
    exit 1
  else
    EXPECTED_BRANCH=$2
  fi

  if ${DEBUG}; then
    echo "Verifying if ${PATCH_FILE} is set to ${EXPECTED_BRANCH}"
  fi

  CLUSTER_BRANCH=$(get_cluster_branch ${PATCH_FILE})

  if [[ "${CLUSTER_BRANCH}" != "${EXPECTED_BRANCH}" ]]; then

    if ${GITHUB}; then
      line_number=$(get_cluster_branch ${PATCH_FILE} true)
            message="Expected \`${EXPECTED_BRANCH}\` but got \`${CLUSTER_BRANCH}\`"
      echo "::error file=${PATCH_FILE},line=${line_number},col=10,title=Incorrect-Branch::${message}"
    else
            echo "Expected ${PATCH_FILE} to be set to \`${EXPECTED_BRANCH}\` but got \`${CLUSTER_BRANCH}\`"
    fi

    ERROR_DETECTED=true
  fi
}

verify_repo() {
  if [ -z "$1" ]; then
    echo "No patch file supplied."
    exit 1
  else
    PATCH_FILE=$1
  fi

  if [ -z "$2" ]; then
    echo "No expected repo supplied."
    exit 1
  else
    EXPECTED_REPO=$2
  fi

  if ${DEBUG}; then
    echo "Verifying if ${PATCH_FILE} is set to ${EXPECTED_REPO}"
  fi

  CLUSTER_REPO=$(get_cluster_repo ${PATCH_FILE})

  if [[ "${CLUSTER_REPO}" != "${EXPECTED_REPO}" ]]; then

    if ${GITHUB}; then
      line_number=$(get_cluster_repo ${PATCH_FILE} true)
            message="Expected \`${EXPECTED_REPO}\` but got \`${CLUSTER_REPO}\`"
      echo "::error file=${PATCH_FILE},line=${line_number},col=10,title=Incorrect-Branch::${message}"
    else
            echo "Expected ${PATCH_FILE} to be set to \`${EXPECTED_REPO}\` but got \`${CLUSTER_REPO}\`"
    fi

    ERROR_DETECTED=true
  fi
}

for cluster in ${CLUSTERS_FOLDER}; do
  if [ -d "${cluster}" ]; then
    verifiy_patch_file "${cluster}/${GIT_PATCH_FILE}"
    verify_branch "${cluster}/${GIT_PATCH_FILE}" ${EXPECTED_BRANCH}
    verify_repo "${cluster}/${GIT_PATCH_FILE}" ${EXPECTED_REPO}

    if ${ERROR_DETECTED}; then
      exit 1
    fi
  fi
done
