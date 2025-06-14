#!/bin/bash

set -e

if [ -z "$1" ]; then
    echo "Usage: $0 <environment>"
    echo "\nEnvironment options: dev, gamma, prod"
    exit 1
fi

export TF_VAR_environment=$1

echo "Starting deletion process..."

# delete the app code first or the finalizers will fail
terraform apply -var environment=dev -target module.f2-infra -auto-approve -destroy
terraform apply -var environment=dev -target module.cnpg -target module.contour -target module.minio -auto-approve -destroy
terraform apply -var environment=dev -target module.longhorn -auto-approve -destroy
terraform apply -auto-approve -destroy

echo "done."
