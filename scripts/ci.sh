#!/bin/bash

# This script runs continuous integration (CI) tasks for the demo-data-product-at-scale project.

# Ensure the script exits on any error
set -e

echo "Running CI tasks for demo-data-product-at-scale..."

# Activate the virtual environment
echo "Activating virtual environment..."
eval "$(pyenv init -)"
eval "$(pyenv virtualenv-init -)"
pyenv activate demo-data-product-at-scale

# Get environment variable from the input (default = dev)
ENVIRONMENT=${1:-dev}

# Run tests to check data product uniqueness
echo "Checking data product name uniqueness..."
python -m pytest tests/test_data_product_uniqueness.py -v

# Get all the files from ./data-products directory that are different from main branch
echo "Checking for modified data product files..."
MODIFIED_FILES=$(git diff --name-only origin/main -- data-products/ | grep -E '\.ya?ml$' || true)
if [ -z "$MODIFIED_FILES" ]; then
    echo "No modified data product files found."
else
    echo "Modified data product files:"
    echo "$MODIFIED_FILES"
fi

# Set Terraform base directory
TERRAFORM_BASE_DIR="src/terraform/output"

# For each modified file, pass it to the python script data-product.py to render the terraform output
if [ -n "$MODIFIED_FILES" ]; then
    echo "$MODIFIED_FILES" | while read -r FILE; do
        if [ -n "$FILE" ]; then
            echo "Generating terraform output for: $FILE"
            python src/python/data-product.py "$ENVIRONMENT" "$FILE" --debug

            echo "Initialise terraform for: $FILE"
            TERRAFORM_DIR="$TERRAFORM_BASE_DIR/$(basename "$FILE" .yaml)"
            
            echo "Initialising Terraform in directory: $TERRAFORM_DIR"
            terraform -chdir="$TERRAFORM_DIR" init -backend-config="backend.config"

            echo "Validating Terraform configuration in directory: $TERRAFORM_DIR"
            terraform -chdir="$TERRAFORM_DIR" validate

            echo "Planning Terraform changes in directory: $TERRAFORM_DIR"
            terraform -chdir="$TERRAFORM_DIR" plan -var-file="data-product.tfvars" -out="data-product.tfplan"
        fi
    done
fi

echo "All CI tasks completed successfully!"