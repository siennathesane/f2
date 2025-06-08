#!/bin/bash

set -e

if [ -z "$1" ]; then
    echo "Usage: $0 <environment>"
    echo "\nEnvironment options: dev, gamma, prod"
    exit 1
fi

export TF_VAR_environment=$1

echo "Starting bootstrap process..."
echo "Initializing Terraform..."
terraform init

echo "Planning Bootstrap Module..."
terraform plan -target module.bootstrap -out=tfplan.bootstrap

echo "Applying Bootstrap Module..."
terraform apply -auto-approve tfplan.bootstrap

echo "Planning Cert-Manager Module..."
terraform plan -target module.cert-manager -out=tfplan.cert-manager

echo "Applying Cert-Manager Module..."
terraform apply -auto-approve tfplan.cert-manager

echo "Planning Terraform CNPG Module..."
terraform plan -target module.cnpg -out=tfplan.cnpg

echo "Applying Terraform CNPG Module..."
terraform apply -auto-approve tfplan.cnpg

echo "Planning f2 Module..."
terraform plan -target module.f2 -out=tfplan.f2

echo "Applying f2 Module..."
terraform apply -auto-approve tfplan.f2

echo "Cleaning up..."
rm tfplan*

echo "done."
