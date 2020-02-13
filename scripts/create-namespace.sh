#!/bin/bash

if [[ -z "$1" ]]; then
  echo "Usage: ./scripts/create-namespace.sh <namespace>"
  exit 1
fi

echo "====> Checking namespace $1"
if ! kubectl get ns $1; then
  echo "====> creating namespace $1"
  kubectl create ns $1
  while ! kubectl get ns $1 > /dev/null ;do
    sleep 5
  done
fi