#!/bin/bash

if ! yq --version 2>/dev/null >/dev/null; then
  echo "Please install yq and try again"
  echo "https://mikefarah.gitbook.io/yq/#install"
  exit 1
fi

while getopts "hcd" arg; do
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
    d)
      DEBUG=true
      ;;
  esac
done

MERGE="m ${ENV_DIR}/values.yaml.gotmpl values.yaml"
KEYS='r - --printMode p "*"'

[[ -n $DEBUG ]] && echo "==> Calculating list of releases"
RELEASES=$(yq ${MERGE} | yq $KEYS)

for release in $RELEASES; do
  [[ -n $DEBUG ]] && echo "==> Checking release $release"
  ENABLED=$(yq ${MERGE} | yq r - "${release}.enabled")
  if [[ "${ENABLED}" =~ ^(true|yes|1|TRUE|YES)$ ]]; then
    [[ -n $DEBUG ]] && echo "----> release $release is enabled"
    NS=$(yq ${MERGE} | yq r - "${release}.namespace")
    if ! kubectl get namespace ${NS} 2>/dev/null >/dev/null; then
      [[ -n $DEBUG ]] && echo "----> namespace $NS is missing"
      if [[ ${CREATE_NS} == "true" ]]; then
        [[ -n $DEBUG ]] && echo "----> creating namespace $NS"
        kubectl create namespace ${NS}
        sleep 5
      else
        [[ -n $DEBUG ]] && echo "----> namespace $NS is exists"
      fi
    fi
  else
    [[ -n $DEBUG ]] && echo "----> release $release is disabled"
  fi
done