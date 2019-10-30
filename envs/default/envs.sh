#!/bin/bash

# name of environment
export ENV_NAME=default

# relative or absolute path of your envs directory, effectively where the directory
# containing this script sits relative to the helmfile dir.
export ENV_DIR="./envs/${ENV_NAME}/"

#export HELMFILE_STATE_VALUES_FILE="$ENV_DIR/values.yaml"

## General
# the DNS name of your PKS cluster
export PKS_HOSTNAME=pks.hostname.com
# the IP address of your PKS cluster
export PKS_IP=35.226.126.245
# the location of the root_ca_certificate (download from opsman)
export ROOT_CA_CERT=~/Downloads/root_ca_certificate

## General
# cloud provider (currently only supports gcp)
export CLOUD_PROVIDER=gcp

## Google
export GOOGLE_PROJECT_ID=pgtm-pczarkowski
# the location of a GCP auth JSON file for a service-account
# needs perms for a bunch of stuff.
export GOOGLE_APPLICATION_CREDENTIALS_FILE="${ENV_DIR}/key.json"
export GOOGLE_APPLICATION_CREDENTIALS_SECRET=$(cat ${GOOGLE_APPLICATION_CREDENTIALS_FILE} | base64 -w0)

## cert-manager
export CERT_MANAGER_EMAIL=nobody@example.com

# full URL for UAA, should be okay to let it derive it.
export UAA_URL=https://${PKS_HOSTNAME}:8443

## external-dns
# pre-created secret containing your GCP creds. gcp-lb-tags chart creates a secret
# we can use here.
export EXTERNAL_DNS_SECRET="google-credentials"
# DNS domain for external-dns controller to manage
export EXTERNAL_DNS_DOMAIN="demo.example.com"

## concourse
export CONCOURSE_ENABLED=false
# The UAA/OIDC user to add to 'main' group in concourse.
export CONCOURSE_OIDC_USER=paul
# hostname to register in DNS
export CONCOURSE_DNS=concourse-cicd.${EXTERNAL_DNS_DOMAIN}
# password for concourse admin user
export CONCOURSE_ADMIN_PASSWORD=sfregredsrfre
# client id and secret for concourse to auth against UAA
export CONCOURSE_OIDC_CLIENT_ID=concourse-cicd
export CONCOURSE_OIDC_CLIENT_SECRET=OyM2bx4JCDN1Q1MpgMIo-JFkwVJlq_ZF

## harbor
export HARBOR_ENABLED=false
# hostname to register in DNS
export HARBOR_DNS=harbor.${EXTERNAL_DNS_DOMAIN}
# GCS bucket to store images in
export HARBOR_GCS_BUCKET=harbor
# A bunch of passwords and secrets that you should change
export HARBOR_ADMIN_PASSWORD=change-me-please
export HARBOR_SECRET_KEY=not-a-secure-key
export HARBOR_DATABASE_PASSWORD=database-password
export HARBOR_INTERNAL_SECRET=safDhgbrtresDF23
# UAA/OIDC client id/secret to use to auth against UAA
export HARBOR_UAA_CLIENT_ID=harbor
export HARBOR_UAA_CLIENT_SECRET=OyM2bx4JCDN1Q1MpgMIo-JFkwVJlq_ZF

## Spinnaker

# UAA/OIDC client settings for Spinnaker
export SPINNAKER_ENABLED=false
export SPINNAKER_DNS=spinnaker-cicd.${EXTERNAL_DNS_DOMAIN}
export SPINNAKER_GATE_DNS=gate.${SPINNAKER_DNS}
export SPINNAKER_UAA_CLIENT_ID=spinnaker-cicd
export SPINNAKER_UAA_CLIENT_SECRET=this-is-a-bad-client-secret
export SPINNAKER_GCS_PROJECT=${CLUSTER_PROJECT}
export SPINNAKER_GCS_BUCKET=${CLUSTER_PROJECT}-spinnaker-petclinic
export SPINNAKER_GCS_AUTH_FILE=${GOOGLE_APPLICATION_CREDENTIALS}
export SPINNAKER_REGISTRY_PASSWORD=vBtAq5UmBvexvOQz3ZDk

## Grafana
export GRAFANA_ADMIN_PASSWORD=password

## Logging

## Elasticsearch
export ELASTICSEARCH_USERNAME=elastic
export ELASTICSEARCH_PASSWORD=flerktj34rt3
