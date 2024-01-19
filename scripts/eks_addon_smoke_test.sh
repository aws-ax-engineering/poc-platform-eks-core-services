#!/usr/bin/env bash
set -eo pipefail

cluster_role=$1

instance_name=$(jq -er .instance_name "environments/$cluster_role".tfvars.json)
export AWS_ACCOUNT_ID=$(cat environments/$cluster_role.tfvars.json | jq -r .aws_account_id)
export AWS_DEFAULT_REGION=$(cat environments/$cluster_role.tfvars.json | jq -r .aws_region)
export AWS_ASSUME_ROLE=$(cat environments/$cluster_role.tfvars.json | jq -r .aws_assume_role)
aws sts assume-role --output json --role-arn arn:aws:iam::$AWS_ACCOUNT_ID:role/$AWS_ASSUME_ROLE --role-session-name cluster-base-configuration-test > credentials

export AWS_ACCESS_KEY_ID=$(cat credentials | jq -r ".Credentials.AccessKeyId")
export AWS_SECRET_ACCESS_KEY=$(cat credentials | jq -r ".Credentials.SecretAccessKey")
export AWS_SESSION_TOKEN=$(cat credentials | jq -r ".Credentials.SessionToken")


# update kubeconfig based on assume-role
aws eks update-kubeconfig --name "$instance_name" \
--region "$AWS_DEFAULT_REGION" \
--role-arn arn:aws:iam::"${AWS_ACCOUNT_ID}":role/"${AWS_ASSUME_ROLE}" --alias "$instance_name" \
--kubeconfig "~/.kube/config"


bats test/*.bats
