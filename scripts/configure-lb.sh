#!/bin/bash

if [[ -z $CLUSTER_NAME ]]; then
  echo "usage:"
  echo ". ./path/to/envs.sh"
  echo "./configure-lb.sh"
  exit 1
fi

gcp-lb-tags create --name ${CLUSTER_NAME} \
   --project ${CLUSTER_PROJECT} --network ${CLUSTER_NETWORK} \
   --region ${CLUSTER_REGION} --port 8443 --tags=service-instance-${CLUSTER_UUID}-master \
   --labels="deployment:service-instance-${CLUSTER_UUID}" --labels="job:master"
