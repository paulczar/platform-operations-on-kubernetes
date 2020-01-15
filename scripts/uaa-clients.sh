#!/bin/bash

if [[ "$1" == "create" ]]; then

uaac client add ${CONCOURSE_OIDC_CLIENT_ID} --scope openid,roles,uaa.user \
  --authorized_grant_types refresh_token,password,authorization_code \
  --redirect_uri "https://${CONCOURSE_DNS}/sky/issuer/callback" \
  --authorities clients.read,clients.secret,uaa.resource,scim.write,openid,scim.read \
  --secret "${CONCOURSE_OIDC_CLIENT_SECRET}"

uaac client add ${HARBOR_OIDC_CLIENT_ID} --scope openid \
  --authorized_grant_types client_credentials,password,refresh_token \
  --redirect_uri "https://${HARBOR_DNS}  https://${HARBOR_DNS}/*" \
  --secret "${HARBOR_OIDC_CLIENT_SECRET}" \
  --authorities clients.read,clients.secret,uaa.resource,scim.write,openid,scim.read

uaac client add "${SPINNAKER_OIDC_CLIENT_ID}" \
  --scope openid,uaa.user,uaa.resource \
  --authorized_grant_types password,refresh_token,authorization_code,client_credentials \
  --redirect_uri "https://${SPINNAKER_GATE_DNS}/login" \
  --secret "${SPINNAKER_OIDC_CLIENT_SECRET}" \
  --authorities uaa.resource

uaac client add "${GRAFANA_OIDC_CLIENT_ID}" \
  --scope openid,profile,email \
  --authorized_grant_types password,refresh_token,authorization_code,client_credentials \
  --redirect_uri "${GRAFANA_URL}/login/generic_oauth" \
  --secret "${GRAFANA_OIDC_CLIENT_SECRET}" \
  --authorities uaa.resource

uaac client add "${ELASTICSEARCH_OIDC_CLIENT_ID}" \
  --scope openid,profile,email \
  --authorized_grant_types password,refresh_token,authorization_code,client_credentials \
  --redirect_uri "${KIBANA_URL}/api/security/v1/oidc" \
  --secret "${ELASTICSEARCH_OIDC_CLIENT_SECRET}" \
  --authorities uaa.resource
exit 0
fi

if [[ "$1" == "destroy" || "$1" == "delete" ]]; then

uaac client delete ${CONCOURSE_OIDC_CLIENT_ID}
uaac client delete ${HARBOR_OIDC_CLIENT_ID}
uaac client delete ${SPINNAKER_OIDC_CLIENT_ID}
uaac client delete ${GRAFANA_OIDC_CLIENT_ID}
uaac client delete ${ELASTICSEARCH_OIDC_CLIENT_ID}

exit 0
fi

echo "Usage: ./scripts/uaa-clients.sh [create|destroy]"
exit 1