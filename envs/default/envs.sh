#!/bin/bash

# name of environment
export ENV_NAME=default

export ENV_DIR="./envs/${ENV_NAME}/"

## General
# cloud provider (currently only supports gcp, leave blank to use minio for local object storage)
export CLOUD_PROVIDER= #gcp


## PKS
# Uncomment this if the cluster is build with PKS
# export PKS=true

## Auth Type, leave blank or `uaa`
export AUTH_TYPE= #uaa

## external-dns
# pre-created secret containing your GCP creds. gcp-lb-tags chart creates a secret
# we can use here.
export EXTERNAL_DNS_SECRET="google-credentials"
# DNS domain for external-dns controller to manage
export EXTERNAL_DNS_DOMAIN="demo.example.com"

## concourse
# hostname to register in DNS
export CONCOURSE_DNS=localhost
# password for concourse admin user
export CONCOURSE_ADMIN_PASSWORD=change-me-please
# external url for concourse
export CONCOURSE_URL=http://${CONCOURSE_DNS}:8080

## harbor
# hostname to register in DNS
export HARBOR_DNS=harbor.${EXTERNAL_DNS_DOMAIN}
# A bunch of passwords and secrets that you should change
export HARBOR_ADMIN_PASSWORD=change-me-please
export HARBOR_SECRET_KEY=not-a-secure-key
export HARBOR_DATABASE_PASSWORD=database-password
export HARBOR_INTERNAL_SECRET=safDhgbrtresDF23

## Spinnaker
# UAA/OIDC client settings for Spinnaker
export SPINNAKER_DNS=spinnaker.${EXTERNAL_DNS_DOMAIN}
export SPINNAKER_GATE_DNS=gate.${SPINNAKER_DNS}
export SPINNAKER_REGISTRY_PASSWORD=vBtAq5UmBvexvOQz3ZDk

## Grafana
export GRAFANA_ADMIN_PASSWORD=password

## Elasticsearch
export ELASTICSEARCH_USERNAME=elastic
export ELASTICSEARCH_PASSWORD=

## Minio
export MINIO_ACCESS_KEY=minio-access-key
export MINIO_SECRET_KEY=minio-secret-key

## kubeapps
# hostname to register in DNS
export KUBEAPPS_DNS=kubeapps.${EXTERNAL_DNS_DOMAIN}
# external url for kubeapps
export KUBEAPPS_URL=https://${KUBEAPPS_DNS}
# base64 cookie secret for when using auth proxy
## use `python -c 'import os,base64; print base64.urlsafe_b64encode(os.urandom(16))'`
export KUBEAPPS_COOKIE_SECRET="not-good-secret"
# mongodb password
export KUBEAPPS_MONGODB_PASSWORD="bad-password"
export KUBEAPPS_MONGODB_ROOT_PASSWORD="bad-root-password"
## kubeapps UAA/OIDC support
# client id and secret for kubeapps to auth against UAA
export KUBEAPPS_OIDC_CLIENT_ID=
export KUBEAPPS_OIDC_CLIENT_SECRET=
export KUBEAPPS_OIDC_URL="${UAA_URL}"

## wavefront
export WAVEFRONT_URL="https://<your>.wavefront.com/"
export WAVEFRONT_TOKEN="<YOUR API TOKEN>"
export WAVEFRONT_CLUSTER_NAME="${ENV_NAME}"
