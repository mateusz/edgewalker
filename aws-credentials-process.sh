#!/bin/bash

if [ -z "$1" ]; then
  echo "Please provide the aws-vault profile as the first parameter."
  exit 1
fi

set -euo pipefail

aws-vault exec $1 -- bash -c 'cat << EOF
{
  "Version": 1,
  "AccessKeyId": "$AWS_ACCESS_KEY_ID",
  "SecretAccessKey": "$AWS_SECRET_ACCESS_KEY",
  "SessionToken": "$AWS_SESSION_TOKEN",
  "Expiration": "$AWS_CREDENTIAL_EXPIRATION"
}
EOF'
