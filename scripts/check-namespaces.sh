#!/bin/bash

if ! yq --version 2>/dev/null >/dev/null; then
  echo "Please install yq and try again"
  echo "https://mikefarah.gitbook.io/yq/#install"
  exit 1
fi

while getopts "hc" arg; do
  case $arg in
    h)
      echo "usage check-namespaces.sh [options]"
      echo "-h help"
      echo "-c create missing namespaces"
      exit 0
      ;;
    c)
      CREATE_NS=true
      ;;
  esac
done

MERGE="m values.yaml ${ENV_DIR}/values.yaml.gotmpl"
KEYS='r - --printMode p "*"'
RELEASES=$(yq ${MERGE} | yq $KEYS)

for release in $RELEASES; do
  ENABLED=$(yq ${MERGE} | yq r - "${release}.enabled")
  if [[ "${ENABLED}" == "true" ]]; then
    NS=$(yq ${MERGE} | yq r - "${release}.namespace")
    if ! kubectl get namespace ${NS} 2>/dev/null >/dev/null; then
      if [[ ${CREATE_NS} == "true" ]]; then
        kubectl create namespace ${NS}
        sleep 5
      fi
    fi
  fi
done