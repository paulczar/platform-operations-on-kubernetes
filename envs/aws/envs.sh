#!/bin/bash

# name of environment
export ENV_NAME=aws

export ENV_DIR="../cluster-envs/${ENV_NAME}/"

# General
## cloud provider ("gcp" or "aws" leave blank to use minio for local object storage)
export CLOUD_PROVIDER=aws

## Custom Root CA Bundle
## allows injecting root CA such as the LE staging CA.
export ROOT_CA_BUNDLE=$(curl -sSL https://letsencrypt.org/certs/fakeleintermediatex1.pem)

## This probably matches EXTERNAL_DNS_DOMAIN, but may be different.
## If you don't use external-dns, you can create a wildcard DNS entry
## Pointing at the service `ingress-nginx-ingress-controller` external IP.
export INGRESS_DNS="${ENV_NAME}.example.com"

## Auth Type, leave blank or `oidc`
export AUTH_TYPE=oidc

## AWS Settings
export AWS_REGION=us-east-2

## KEYCLOAK
export KEYCLOAK_ADMIN_USER=admin
export KEYCLOAK_ADMIN_PASSWORD=not-a-good-password
export KEYCLOAK_DNS="auth.${INGRESS_DNS}"
export KEYCLOAK_URL="https://${KEYCLOAK_DNS}"

## up to 5 users
export KEYCLOAK_USERS_0_USER=fred
export KEYCLOAK_USERS_0_PASS=fred-has-a-bad-password
export KEYCLOAK_USERS_0_EMAIL=fred@example.com
export KEYCLOAK_USERS_1_USER=test
export KEYCLOAK_USERS_1_PASS=test-has-a-bad-password
export KEYCLOAK_USERS_1_EMAIL=test@example.com


## Generic OIDC (defaults assume keycloak)
export OIDC_URL="${KEYCLOAK_URL}/auth/realms/master"
export OIDC_AUTH_URL="${OIDC_URL}/protocol/openid-connect/auth"
export OIDC_TOKEN_URL="${OIDC_URL}/protocol/openid-connect/token"
export OIDC_USER_INFO_URL="${OIDC_URL}/protocol/openid-connect/userinfo"
## cert-manager
export CERT_MANAGER_EMAIL=username.taken@gmail.com

## harbor
# hostname to register in DNS
export HARBOR_DNS=harbor.${INGRESS_DNS}
export HARBOR_URL=https://${HARBOR_DNS}
# A bunch of passwords and secrets that you should change
export HARBOR_ADMIN_PASSWORD=change-me-please
export HARBOR_SECRET_KEY=not-a-secure-key
export HARBOR_DATABASE_PASSWORD=database-password
export HARBOR_INTERNAL_SECRET=safDhgbrtresDF23
export HARBOR_CORE_SECRET_KEY=SzTHVJtb7EW6WTmL
export HARBOR_CSRFKEY="FDh8cR9Xh7F72FLUx9K4Z4ijO62DA1XIxctp0K8V"
## harbor UAA auth
# UAA/OIDC client id/secret to use to auth against UAA
export HARBOR_OIDC_URL=${OIDC_URL}
export HARBOR_OIDC_CLIENT_ID=harbor
export HARBOR_OIDC_CLIENT_SECRET=da44fca8-98ed-4403-957f-235d1850a577

## Harbor Object Storage
export HARBOR_IMAGE_STORAGE_BUCKET="${ENV_NAME}-harbor"
## Harbor GCP Object Storage
# should be base64 encoded credentials.json with object storage access
export HARBOR_GCP_CREDENTIALS=${GOOGLE_APPLICATION_CREDENTIALS_SECRET}
## Harbor S3 Object Storage
export HARBOR_S3_ACCESS_KEY=
export HARBOR_S3_SECRET_KEY=
export HARBOR_S3_REGION=${AWS_REGION}

## Grafana
export GRAFANA_ADMIN_PASSWORD=password
export GRAFANA_DNS=grafana.${INGRESS_DNS}
export GRAFANA_URL=https://${GRAFANA_DNS}
## Grafana Oauth/UUA/OpenID
export GRAFANA_OIDC_CLIENT_ID=grafana
export GRAFANA_OIDC_CLIENT_SECRET="942f47ea-4186-4b32-b136-4f6a5aae2f59"
export GRAFANA_OIDC_AUTH_URL="${OIDC_AUTH_URL}"
export GRAFANA_OIDC_TOKEN_URL="${OIDC_TOKEN_URL}"
export GRAFANA_OIDC_USERINFO_URL="${OIDC_USER_INFO_URL}"

## Loki
export LOKI_GCS_CREDENTIALS=${GOOGLE_APPLICATION_CREDENTIALS_SECRET}
export LOKI_GCS_PROJECT=${GOOGLE_PROJECT_ID}
export LOKI_GCS_BUCKET=${ENV_NAME}-loki


## Minio
export MINIO_ACCESS_KEY=minio-access-key
export MINIO_SECRET_KEY=minio-secret-key
