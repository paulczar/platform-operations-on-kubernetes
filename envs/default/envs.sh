#!/bin/bash

# name of environment
export ENV_NAME=default

# relative or absolute path of your envs directory, effectively where the directory
# containing this script sits relative to the helmfile dir.
export ENV_DIR="./envs/${ENV_NAME}/"

## General
# cloud provider (currently only supports gcp, leave blank to use minio for local object storage)
# export CLOUD_PROVIDER=gcp

## PKS
# Uncomment this if the cluster is build with PKS
# export PKS=true

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
export SPINNAKER_DNS=spinnaker-cicd.${EXTERNAL_DNS_DOMAIN}
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