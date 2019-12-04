# Platform Operations on Kubernetes

This project demonstrates how to set up and Platform Operations infrastructure on Kubernetes by providing a Reference Implementation of many platform level components such as CI, CD, Metrics, Logging, Policy Enforcement and security.

It uses Pivotal Container Service (PKS) as the Kubernetes provider with RBAC being provided by UAA, but most of this should work without, you'll just have to find an alternative authentication method for your apps.

We take advantage of a few tools to streamline things, firstly [Helm](https://helm.sh) as all of the infrastructure tooling is available in public Helm charts (although some charts may be vendored in here for custom changes). We also use Helmfile which is a project that allows you to compose Helm Charts together.

With the goal of doing a gitops style workflow for deploying this, it is expected that you'll have seperate `env` directory(s) containing the customizations for a particular environment or cluster. The example included is not fully functioning, but should be fairly simple to get working.

For the most part you should just need to edit `envs/default/envs.sh` and fill it in with your details. This is a shell script that will export environment variables to be used by Helmfile. The reason for this is that if you have passwords/secrets you can store them outside of git and have the script extract them from wherever you keep them.

## Download tools

It's expected that you already have the basic Kubernetes client tools like `kubectl` installed.

### Helm

* [helm](https://helm.sh/docs/using_helm/#quickstart-guide)
* [helmfile](https://github.com/roboll/helmfile#installation)
* [helmdiff](https://github.com/databus23/helm-diff#install)
* [helm tillerless](https://github.com/rimusz/helm-tiller#installation)

## Prepare environment

### Create Kubernetes Cluster

If you don't already have a Kubernetes cluster you should use PKS or GKE to create one.

wait for cluster to be ready...

### Prepare Helm

Download and Install [Helm 2](https://github.com/helm/helm/releases/tag/v2.15.2).

Install the helm diff and tillerless plugins:

```bash
helm init --client-only

helm plugin install https://github.com/databus23/helm-diff

helm plugin install https://github.com/rimusz/helm-tiller

helm tiller install
```

### Fill out envs.sh

If you want to customize your deployment copy the contents of `/envs/default` to another location and modify `envs.sh` and `values.yaml` accordingly.

### Load env and create DNS

> Note: If you changed the location of your environment you'll need to modify this command.

```bash
. ./envs/default/envs.sh

```
ensure kubectl is working

```bash
$ kubectl get nodes
NAME                                      STATUS   ROLES    AGE   VERSION
vm-5ca56981-6249-4d31-613e-7d84821b245e   Ready    <none>   46m   v1.13.5
vm-5fb78083-d502-43b3-4e01-d664fdb147dc   Ready    <none>   42m   v1.13.5
vm-b451253c-e485-4d99-7bb4-1cfe222bf4ac   Ready    <none>   39m   v1.13.5
```

## Configuration

Poke through `envs/default/envs.sh` it should be pretty obvious what you need to set.
Ideally you'll copy this directory somewhere and modify and use it outside the scope of this git repository.

### Configure ingress

Not really anything to do here, defaults should be fine.

### Configure cert-manager

set `certManager.enabled: true` in `values.yaml` if you want TLS certificates.

### Concourse

```bash
. ./envs/default/envs.sh
uaac client add ${CONCOURSE_OIDC_CLIENT_ID} --scope openid,roles,uaa.user \
  --authorized_grant_types refresh_token,password,authorization_code \
  --redirect_uri "https://${CONCOURSE_DNS}/sky/issuer/callback" \
  --authorities clients.read,clients.secret,uaa.resource,scim.write,openid,scim.read \
  --secret "${CONCOURSE_OIDC_CLIENT_SECRET}"
```

### Harbor

Harbor will autogenerate certificates for notary, but it will regenerate them every time helm runs, which is painful. You can should create your own secret based on it, but we've provided a default to get you going:

```bash
kubectl create namespace harbor
kubectl -n harbor apply -f ./resources/harbor/notary-certs-secret.yaml
```

Harbor also needs your UAA server's CA Cert. You can create a secret for it like so:

```bash
. ./envs/default/envs.sh
kubectl -n harbor create secret generic \
   uaa-ca-cert --from-file=ca.crt=$ROOT_CA_CERT
```

You also need to create a client in your UAA server for harbor:

```bash
. ../envs/default/envs.sh
uaac client add ${HARBOR_UAA_CLIENT_ID} --scope openid \
  --authorized_grant_types client_credentials,password,refresh_token \
  --redirect_uri 'https://${HARBOR_URL}  https://${HARBOR_URL}/*' \
  --secret "${HARBOR_UAA_CLIENT_SECRET}" \
  --authorities clients.read,clients.secret,uaa.resource,scim.write,openid,scim.read
```

### Spinnaker

Create a namespace for spinnaker:

```bash
kubectl create namespace spinnaker
```

In order for Spinnaker to trust UAA's CA CERT we need to construct a new java cert store that includes our UAA cert:

```bash
. ./envs/default/envs.sh
cp /etc/ssl/certs/java/cacerts /tmp/cacerts
echo "changeit" | keytool -importcert -alias uaa-ca \
    -keystore /tmp/cacerts -noprompt -file $ROOT_CA_CERT
kubectl -n spinnaker create secret generic \
    java-ca-certs --from-file /tmp/cacerts
```

Create a UAA client for spinnaker:

```bash
. ./envs/default/envs.sh
uaac client add "${SPINNAKER_UAA_CLIENT_ID}" \
  --scope openid,uaa.user,uaa.resource \
  --authorized_grant_types password,refresh_token,authorization_code,client_credentials \
  --redirect_uri "https://${SPINNAKER_GATE_DNS}/login" \
  --secret "${SPINNAKER_UAA_CLIENT_SECRET}" \
  --authorities uaa.resource
```

 Create a secret from the client secret we just created:

```bash
. ./envs/default/envs.sh
kubectl -n spinnaker create secret generic \
  spinnaker-additional-secrets \
  --from-literal="oauth2_client_secret=${SPINNAKER_UAA_CLIENT_SECRET}"
```

Create a secret from a google service account JSON file that has GCS access:

```bash
. ./envs/default/envs.sh
kubectl -n spinnaker create secret generic gcs-creds \
  --from-file="key.json=${SPINNAKER_GCS_AUTH_FILE}"
```

Create a secret for your registry auth:

```bash
. ./envs/default/envs.sh
kubectl -n spinnaker create secret generic registry-secret \
    --from-literal="dockerhub=${SPINNAKER_REGISTRY_PASSWORD}"
```

## Install that shizzle

```bash
helmfile --state-values-file $ENV_DIR/values.yaml diff
```


k create service externalname k8s-api --external-name 245.126.226.35.bc.googleusercontent.com
k annotate service k8s-api external-dns.alpha.kubernetes.io/hostname=k8s.cluster2.demo.paulczar.wtf


k create secret generic gcp-lb-tags --from-file credentials.json=../cluster-envs/google.json

k create secret generic google-credentials --from-file credentials.json=../cluster-envs/google.json