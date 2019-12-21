#!/bin/bash

# name of environment
export ENV_NAME=gcp-uaa-openid

# relative or absolute path of your envs directory, effectively where the directory
# containing this script sits relative to the helmfile dir.
export ENV_DIR="./envs/${ENV_NAME}/"

## General
# cloud provider (currently only supports gcp, leave blank to use minio for local object storage)
export CLOUD_PROVIDER=gcp

## Google
export GOOGLE_PROJECT_ID=

## external-dns and cert-manager need access to a service account with DNS management
## Given a downloaded creds json file this will load it into a secret.
export GOOGLE_APPLICATION_CREDENTIALS_FILE="../cluster-envs/key.json"
if [[ -e $GOOGLE_APPLICATION_CREDENTIALS_FILE ]]; then
  export GOOGLE_APPLICATION_CREDENTIALS_SECRET=$(cat ${GOOGLE_APPLICATION_CREDENTIALS_FILE} | base64 -w0)
fi

## external-dns
# pre-created secret containing your GCP creds. This is created from the above
export EXTERNAL_DNS_SECRET="google-credentials"
# DNS domain for external-dns controller to manage should be a google dns
# managed zone
export EXTERNAL_DNS_DOMAIN=

## cert-manager
export CERT_MANAGER_EMAIL=

export AUTH_TYPE=uaa

## UAA/OIDC
## the endpoint $UAA_URL/.well-known/openid-configuration should
## help you fill out UAA/OIDC fields for services below
export UAA_URL=https://pks.${EXTERNAL_DNS_DOMAIN}:8443
export UAA_ROOT_CA_CERT= #$(cat ~/Downloads/root_ca_certificate)


## concourse
# hostname to register in DNS
export CONCOURSE_DNS=concourse.${EXTERNAL_DNS_DOMAIN}
# password for concourse admin user
export CONCOURSE_ADMIN_PASSWORD=change-me-please
# external url for concourse
export CONCOURSE_URL=https://${CONCOURSE_DNS}
## concourse UAA/OIDC support
# The UAA/OIDC user to add to 'main' group in concourse.
export CONCOURSE_OIDC_USER=pksadmin
# client id and secret for concourse to auth against UAA
export CONCOURSE_OIDC_CLIENT_ID=concourse
export CONCOURSE_OIDC_CLIENT_SECRET=a-bad-client-secret


## harbor
# hostname to register in DNS
export HARBOR_DNS=harbor.${EXTERNAL_DNS_DOMAIN}
# A bunch of passwords and secrets that you should change
export HARBOR_ADMIN_PASSWORD=change-me-please
export HARBOR_SECRET_KEY=not-a-secure-key
export HARBOR_DATABASE_PASSWORD=database-password
export HARBOR_INTERNAL_SECRET=safDhgbrtresDF23
export HARBOR_XSRFKEY=FDh8cR9Xh7F72FLUx9K4Z4ijO62DA1XIxctp0K8V
## harbor UAA auth
# UAA/OIDC client id/secret to use to auth against UAA
export HARBOR_OIDC_CLIENT_ID=harbor
export HARBOR_OIDC_CLIENT_SECRET=a-bad-client-secret
IFS='' read -r -d '' HARBOR_USER_SETTINGS_JSON <<JSON
  {
    "auth_mode": "uaa_auth",
    "uaa_client_id": "$HARBOR_OIDC_CLIENT_ID",
    "uaa_client_secret": "$HARBOR_OIDC_CLIENT_SECRET",
    "uaa_endpoint": "$UAA_URL",
    "uaa_verify_cert": "true"
  }
JSON
## Harbor GCP Object Storage
# should be base64 encoded credentials.json with object storage access
export HARBOR_GCP_CREDENTIALS=${GOOGLE_APPLICATION_CREDENTIALS_SECRET}

## Spinnaker
# UAA/OIDC client settings for Spinnaker
export SPINNAKER_DNS=spinnaker.${EXTERNAL_DNS_DOMAIN}
export SPINNAKER_GATE_DNS=api.${SPINNAKER_DNS}
export SPINNAKER_REGISTRY_PASSWORD=vBtAq5UmBvexvOQz3ZDk
# client id and secret for concourse to auth against UAA
export SPINNAKER_OIDC_CLIENT_ID=spinnaker
export SPINNAKER_OIDC_CLIENT_SECRET=a-bad-client-secret
## Spinnaker  GCP Object Storage
# should be base64 encoded credentials.json with object storage access
export SPINNAKER_GCS_CREDENTIALS=${GOOGLE_APPLICATION_CREDENTIALS_SECRET}
export SPINNAKER_GCS_PROJECT=${GOOGLE_PROJECT_ID}
export SPINNAKER_GCS_BUCKET=${ENV_NAME}-spinnaker

## Grafana
export GRAFANA_ADMIN_PASSWORD=password
export GRAFANA_DNS=grafana.${EXTERNAL_DNS_DOMAIN}
export GRAFANA_URL=https://${GRAFANA_DNS}
## Grafana Oauth/UUA/OpenID
export GRAFANA_OIDC_CLIENT_ID=grafana
export GRAFANA_OIDC_CLIENT_SECRET=a-bad-client-secret
export GRAFANA_OIDC_AUTH_URL=${UAA_URL}/oauth/authorize
export GRAFANA_OIDC_TOKEN_URL=${UAA_URL}/oauth/token
export GRAFANA_OIDC_USERINFO_URL=${UAA_URL}/userinfo

## Elasticsearch
export ELASTICSEARCH_USERNAME=elastic
export ELASTICSEARCH_PASSWORD=change-this-password
## Elasticsearch OAuth/UAA/OpenID
export ELASTICSEARCH_OIDC_CLIENT_ID=elasticsearch
export ELASTICSEARCH_OIDC_CLIENT_SECRET=a-bad-client-secret
export ELASTICSEARCH_OIDC_AUTH_URL=${UAA_URL}/oauth/authorize
export ELASTICSEARCH_OIDC_TOKEN_URL=${UAA_URL}/oauth/token
export ELASTICSEARCH_OIDC_USERINFO_URL=${UAA_URL}/userinfo
export ELASTICSEARCH_OIDC_LOGOUT_URL=${UAA_URL}/userinfo
export ELASTICSEARCH_OIDC_JWKS_URL=${UAA_URL}/token_keys

## Kibana
export KIBANA_DNS=kibana.${EXTERNAL_DNS_DOMAIN}
export KIBANA_URL=https://${KIBANA_DNS}

## Minio
export MINIO_ACCESS_KEY=
export MINIO_SECRET_KEY=