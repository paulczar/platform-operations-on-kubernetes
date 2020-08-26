# POOK on AWS

> Note: this is tested on a VMware TMC cluster provisioned to AWS

## PreReqs

* [kubectl](https://kubernetes.io)
* [helm](https://helm.sh/docs/using_helm/#quickstart-guide)
* [helmfile](https://github.com/roboll/helmfile#installation)
* [helmdiff](https://github.com/databus23/helm-diff#install)

## Set up envs repo

1. Copy `./envs/aws` to another directory:

  ```bash
  cp -r ./envs/aws ../cluster-envs/aws
  ```

1. Make sure `ENV_NAME` and `ENV_DIR` are correct in `../cluster-envs/aws/envs.sh`

1. Go through the values in `../cluster-envs/aws/envs.sh` and change any passwords/secrets

1. Source the envs:

  ```bash
  . ../cluster-envs/aws/envs.sh
  ```


## Set up S3 credentials

> Note: You can skip this and instead set `charts.minio.enabled=true` in `../cluster-envs/aws/charts.yaml.gotmpl`

1. Create user for Harbor

  ```bash
  aws iam create-user --user-name ${ENV_NAME}-harbor
  ```

2. Create access keys for Harbor and save them as `HARBOR_S3_ACCESS_KEY` and `HARBOR_S3_SECRET_KEY` in `../cluster-envs/aws/envs.sh`
  ```bash
  aws iam create-access-key --user-name $ENV_NAME-harbor
  ```

3. Create an s3 bucket for Harbor
  ```bash
  aws s3 mb s3://${HARBOR_IMAGE_STORAGE_BUCKET} --region ${AWS_REGION}
  ```

4. Set user policy to give harbor access to the s3 bucket

aws iam put-user-policy --user-name ${ENV_NAME}-harbor --policy-name ${ENV_NAME}-harbor-bucket-access --policy-document "{\"Version\":\"2012-10-17\",\"Statement\":[{\"Effect\":\"Allow\",\"Action\":[\"s3:*\"],\"Resource\":[\"arn:aws:s3:::${HARBOR_IMAGE_STORAGE_BUCKET}\"]},{\"Effect\":\"Allow\",\"Action\":[\"s3:*\"],\"Resource\":[\"arn:aws:s3:::${HARBOR_IMAGE_STORAGE_BUCKET}/*\"]}]}"


## DNS / INGRESS

1. set `INGRESS_DNS` in `envs.sh` to a dns suffix that you control (we'll create a wildcard dns entry for this later).

## Deploy

1. Reload up your Environment variables:

  ```bash
  . ../cluster-envs/aws/envs.sh
  ```

1. run helmfile apply

  ```bash
  helmfile apply --suppress-secrets
  ```

  > Note: this may fail due to CRD install order, a second run should fix it.


1. Get the external IP of the ingress controller service:

1. Update your DNS provider to use this IP for your wildcard DNS.