#!/usr/bin/env bash
set -eo pipefail

cluster_role=$1
instance_name=$(jq -er .instance_name "$cluster_role".auto.tfvars.json)

# add POCServiceAccount credentials to cluster
cat <<EOF | kubectl apply -f -
apiVersion: v1
kind: Secret
metadata:
  name: aws-secret
  namespace: upbound-system
stringData:
  creds: |
    $(printf "[default]\n    aws_access_key_id = %s\n    aws_secret_access_key = %s" "${AWS_ACCESS_KEY_ID}" "${AWS_SECRET_ACCESS_KEY}")
EOF

cat <<EOF | kubectl apply -f -
apiVersion: aws.upbound.io/v1beta1
kind: ProviderConfig
metadata:
  name: default
spec:
  credentials:
    source: Secret
    secretRef:
      namespace: upbound-system
      name: aws-secret
      key: creds
EOF
