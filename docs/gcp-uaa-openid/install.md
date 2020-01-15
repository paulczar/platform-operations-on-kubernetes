# Platform Operations on Kubernetes on GCP with UAA / OpenID auth

This example demonstrates running on a cluster running inside of Google Cloud with access to a UAA server for authentication for all services. It should work with most openid providers with minimal change.

With OpenID auth in place all services will be made available to the public internet via an nginx ingress controller and secured with `cert-manager` and `external-dns`. These will be installed into a `cluster-admin` namespace.

The following components are installed in the default environment:

* Grafana
* Prometheus
* EFK (Elasticsearch, Fluentd, Kibana)
* Concourse
* Harbor
* Spinnaker

## Prepare GCP resources account

### Envs

Copy `envs/gcp-uaa-openid`:

```console
mkdir -p ../cluster-envs/example-gcp-openid
cp -r envs/gcp-uaa-openid/* ../cluster-envs/example-gcp-openid
```

edit ../cluster-envs/example-gcp-openid/envs.sh` and set the following:

* `ENV_NAME=example-gcp-openid`
* `EXTERNAL_DNS_DOMAIN=` - the DNS zone you wish to use for a google managed DNS
* `ENV_DIR="./envs/${ENV_NAME}/"`
* `GOOGLE_PROJECT_ID=` - your GCP project ID
* `CERT_MANAGER_EMAIL` - your email to receive cert expiry notifications
* `GOOGLE_APPLICATION_CREDENTIALS_FILE` - path to which you want to download your google credentials to.
* `UAA_URL` the URL of your UAA server
* `UAA_ROOT_CA_CERT` the CA cert for your UAA server if self signed.

Look for variables with `OIDC` or `UAA` and modify them to suit.

Load the modified envs file:

```console
. ../cluster-envs/example-gcp-openid/envs.sh
```

### Create a DNS Zone

```console
gcloud dns managed-zones create pook-$ENV_NAME \
  --dns-name $EXTERNAL_DNS_DOMAIN \
  --description "managed zone for POOK $ENV_NAME"
```

### Create a GCP service account for DNS management and Cloud Storage

Create service account:

```console
gcloud iam service-accounts create \
    pook-${ENV_NAME} --display-name "POOK service account"
```

Assign permissions:

```console
EMAIL=pook-${ENV_NAME}@$GOOGLE_PROJECT_ID.iam.gserviceaccount.com

gcloud projects add-iam-policy-binding $GOOGLE_PROJECT_ID \
  --member serviceAccount:$EMAIL --role roles/dns.admin

gcloud projects add-iam-policy-binding $GOOGLE_PROJECT_ID \
  --member serviceAccount:$EMAIL --role roles/storage.admin
```

Download a google credentials file into your new envs directory:

```console
gcloud iam service-accounts keys create \
  ../cluster-envs/key.json --iam-account=$EMAIL
```

Load your envs file again to pick up this key:

```console
. ../cluster-envs/example-gcp-openid/envs.sh
```

## Create Kubernetes Cluster

If you don't already have a Kubernetes cluster you should use PKS or GKE to create one.

Wait for cluster to be ready...

Ensure kubectl is working

```bash
$ kubectl get nodes
NAME                                      STATUS   ROLES    AGE   VERSION
vm-5ca56981-6249-4d31-613e-7d84821b245e   Ready    <none>   46m   v1.13.5
vm-5fb78083-d502-43b3-4e01-d664fdb147dc   Ready    <none>   42m   v1.13.5
vm-b451253c-e485-4d99-7bb4-1cfe222bf4ac   Ready    <none>   39m   v1.13.5
```

## Prepare Helm

Download and Install [Helm 2](https://github.com/helm/helm/releases/tag/v2.15.2).

Install the helm diff and tillerless plugins:

```bash
helm init --client-only

helm plugin install https://github.com/databus23/helm-diff

helm plugin install https://github.com/rimusz/helm-tiller

helm tiller install
```


## Fill out envs.sh

If you want to customize your deployment copy the contents of `/envs/default` to another location and modify `envs.sh` and `values.yaml` accordingly.

## Load environment

> Note: If you changed the location of your environment you'll need to modify this command.

```bash
. ./envs/default/envs.sh

```

## Create CRDs for certmanager

```bash
kubectl apply --validate=false \
    -f https://raw.githubusercontent.com/jetstack/cert-manager/release-0.12/deploy/manifests/00-crds.yaml
```

## Create UAA/OIDC clients

> Note: You can skip manually creating the clients by running the script `./scripts/uaa-clients.sh create`.

Install the UAA CLI (ruby):

```bash
sudo gem install cf-uaac
```

Log into UAA:

```bash
uaac target $UAA_URL
uaac token client get admin -s "<uaa-admin-secret-goes-here>"
```

If you need to create additional UAA users you can do it like so:

```bash
uaac user add test -p testfred1234 --emails test@here.com
```

### Concourse

Create UAA Client:

```bash
uaac client add ${CONCOURSE_OIDC_CLIENT_ID} --scope openid,roles,uaa.user \
  --authorized_grant_types refresh_token,password,authorization_code \
  --redirect_uri "https://${CONCOURSE_DNS}/sky/issuer/callback" \
  --authorities clients.read,clients.secret,uaa.resource,scim.write,openid,scim.read \
  --secret "${CONCOURSE_OIDC_CLIENT_SECRET}"
  ```

### Harbor

Create storage bucket:

```bash
  gsutil mb -p $GOOGLE_PROJECT_ID -l us-central1 gs://$ENV_NAME-harbor/
```

Create UAA Client:

```bash
uaac client add ${HARBOR_OIDC_CLIENT_ID} --scope openid \
  --authorized_grant_types client_credentials,password,refresh_token \
  --redirect_uri "https://${HARBOR_DNS}  https://${HARBOR_DNS}/*" \
  --secret "${HARBOR_OIDC_CLIENT_SECRET}" \
  --authorities clients.read,clients.secret,uaa.resource,scim.write,openid,scim.read
  ```

### Spinnaker

If you have a self signed certificate for your UAA server you'll need to load up a secret with it:

> Note: this example was performed on a linux machine. OSX/Windows may need modifications

```bash
cp /etc/ssl/certs/java/cacerts /tmp/cacerts
echo "changeit" | keytool -importcert -alias uaa-ca \
    -keystore /tmp/cacerts -noprompt -file $UAA_ROOT_CA_FILE
kubectl create namespace spinnaker
kubectl -n spinnaker create secret generic \
    java-ca-certs --from-file /tmp/cacerts
```

Create a UAA Client for Spinnaker

```bash
uaac client add "${SPINNAKER_OIDC_CLIENT_ID}" \
  --scope openid,uaa.user,uaa.resource \
  --authorized_grant_types password,refresh_token,authorization_code,client_credentials \
  --redirect_uri "https://${SPINNAKER_GATE_DNS}/login" \
  --secret "${SPINNAKER_OIDC_CLIENT_SECRET}" \
  --authorities uaa.resource
  ```

### Grafana

Create a UAA Client for Grafana

```bash
uaac client add "${GRAFANA_OIDC_CLIENT_ID}" \
  --scope openid,profile,email \
  --authorized_grant_types password,refresh_token,authorization_code,client_credentials \
  --redirect_uri "${GRAFANA_URL}/login/generic_oauth" \
  --secret "${GRAFANA_OIDC_CLIENT_SECRET}" \
  --authorities uaa.resource
  ```

### Elasticsearch / Kibana

Create a UAA Client for Elasticsearch

```bash
uaac client add "${ELASTICSEARCH_OIDC_CLIENT_ID}" \
  --scope openid,profile,email \
  --authorized_grant_types password,refresh_token,authorization_code,client_credentials \
  --redirect_uri "${KIBANA_URL}/api/security/v1/oidc" \
  --secret "${ELASTICSEARCH_OIDC_CLIENT_SECRET}" \
  --authorities uaa.resource
  ```

> Note: `sudo sysctl -w vm.max_map_count=262144` must be set on your worker nodes for elasticsearch to start correctly.



## Install using helmfile

```bash
helmfile --state-values-file $ENV_DIR/values.yaml.gotmpl apply
```

## Check services

Check that your ingress resources are up and have DNS and an IP address:

```bash
$ kubectl get ingress --all-namespaces
NAMESPACE   NAME                       HOSTS                                      ADDRESS        PORTS     AGE
concourse   concourse-web              concourse.example.com       55.66.33.22   80, 443   47h
gangway     gangway                    gangway.example.com         55.66.33.22   80, 443   20h
harbor      harbor-harbor-ingress      harbor.example.com          55.66.33.22   80, 443   47h
logging     kibana-kibana              kibana.example.com          55.66.33.22   80, 443   47h
metrics     grafana                    grafana.example.com         55.66.33.22   80, 443   47h
spinnaker   spinnaker-spinnaker-deck   spinnaker.example.com       55.66.33.22   80, 443   47h
spinnaker   spinnaker-spinnaker-gate   api.spinnaker.example.com   55.66.33.22   80, 443   47h
```

### Grafana

Point your web browser at `https://$GRAFANA_DNS`, log in via OIDC and then browse to the `cluster-monitoring-for-kubernetes` dashboard.

![grafana dashboard](./grafana.png)

### Kibana


UAA/OIDC Auth requires an Elastic license you can start a 30 day trial like so:

```bash
kubectl -n logging exec -ti elasticsearch-master-0 \
  -- curl -k -X POST "https://elastic:${ELASTICSEARCH_PASSWORD}@localhost:9200/_license/start_trial?acknowledge=true&pretty"
```

You also need to do some role mapping, the following will give all oidc users access to kibana:

```bash
kubectl -n logging exec -ti elasticsearch-master-0 \
-- curl -k -X POST "https://elastic:${ELASTICSEARCH_PASSWORD}@localhost:9200/_security/role/kubernetes_indices?pretty" -H 'Content-Type: application/json' -d '
{"cluster":[],"indices":[{"names":["kubernetes_cluster-*"],"privileges":["read"]}]}'

kubectl -n logging exec -ti elasticsearch-master-0 \
-- curl -k -X POST "https://elastic:${ELASTICSEARCH_PASSWORD}@localhost:9200/_security/role_mapping/oidc-kibana?pretty" -H 'Content-Type: application/json' -d'
{
  "roles": ["kibana_user","kubernetes_indices" ],
  "enabled": true,"rules": {"field": { "realm.name": "oidc1" }}
}'
```

Point your web browser at `https://$KIBANA_DNS/app/kibana#/discover`

![kibana dashboard](./kibana.png)

### Harbor

```

Once deployed you need to tell the API to use the provided UAA authentication:

```bash
curl -i -X PUT -u "admin:$HARBOR_ADMIN_PASSWORD" \
-H "Content-Type: application/json" \
  https://$HARBOR_DNS/api/configurations \
  -d $HARBOR_USER_SETTINGS_JSON
```

Log into registry and push an image:

> Note: we're using the pre-defined harbor admin user/pass here to avoid having to manually create a repository first.

```console
$ docker login $HARBOR_DNS
Username: admin
Password: ******
Login Succeeded
```

```console
docker pull alpine:latest
docker tag alpine:latest $HARBOR_DNS/library/alpine:latest
docker push $HARBOR_DNS/library/alpine:latest
```

Browse to [https://$HARBOR_DNS](https://$HARBOR_DNS) in your web browser and login using your UAA credentials.

```console
firefox https://$HARBOR_DNS
```

You should be able to see your recently pushed alpine image at [https://$HARBOR_DNS/harbor/projects/1/repositories](https://harbor:8443/harbor/projects/1/repositories).

![harbor](./harbor.png)

### Concourse

Browse to [$CONCOURSE_URL]($CONCOURSE_URL) in your web browser and login using your UAA creds.

```console
firefox $CONCOURSE_URL
```

![Concourse](./concourse.png)

### Spinnaker

Forward a port for Spinnaker

```console
kubectl -n spinnaker port-forward svc/spin-deck 9000
```

Browse to [$SPINNAKER_URL](SPINNAKER_URL) in your web browser.

```console
firefox $SPINNAKER_URL
```

![Spinnaker](./spinnaker.png)
