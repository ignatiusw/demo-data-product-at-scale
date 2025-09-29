#!/bin/bash

# This script runs continuous deployment (CD) tasks for the demo-data-product-at-scale project.
# It applies Terraform plans for modified data product files to the specified environment.

# Ensure the script exits on any error
set -e

echo "Running CD tasks for demo-data-product-at-scale..."

# Set Terraform base directory
TERRAFORM_BASE_DIR="src/terraform/output"

# Loop through each subfolder under the terraform base directory and apply the Terraform plan if it exists
for dir in "$TERRAFORM_BASE_DIR"/*/; do
    if [ -d "$dir" ]; then
        echo "Applying Terraform plan in directory: $dir"
        if [ -f "$dir/data-product.tfplan" ]; then
            terraform -chdir="$dir" apply "data-product.tfplan"
        else
            echo "No Terraform plan found in $dir, skipping..."
        fi
    fi
done

echo "All CD tasks completed successfully!"