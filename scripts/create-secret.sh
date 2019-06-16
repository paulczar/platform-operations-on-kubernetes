#!/bin/bash

FILE=$1
KEY=$2
NAME=$3
NAMESPACE=$4

if [[ -z $FILE ]] || [[ -z KEY ]] || [[ -z NAME ]] || [[ -z NAMESPACE ]]; then
  echo Usage: ./create-secret.sh /path/to/file key name namespace
  exit 1
fi

VALUE=$(cat ${FILE} | base64 -w 0)

echo "
apiVersion: v1
kind: Namespace
metadata:
  name: $NAMESPACE
---
apiVersion: v1
kind: Secret
metadata:
  name: $NAME
  namespace: $NAMESPACE
type: Opaque
data:
  $KEY: $VALUE
" | kubectl apply -f -