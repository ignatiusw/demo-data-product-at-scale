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

# Get all the files from ./data-products directory
echo "Checking for modified data product files..."
ALL_FILES=$(find data-products/ -type f \( -name "*.yaml" -o -name "*.yml" \) | sort || true)
if [ -z "$ALL_FILES" ]; then
    echo "No data product files found."
else
    echo "Data product files found:"
    echo "$ALL_FILES"
fi

# Set Terraform base directory
TERRAFORM_BASE_DIR="src/terraform/output"

# Generate terraform output for all data products
echo "Generating terraform output for all data products..."
python src/python/data-product.py "$ENVIRONMENT" "data-products/" --debug

# For each modified file, pass it to the python script data-product.py to render the terraform output
if [ -n "$ALL_FILES" ]; then
    echo "$ALL_FILES" | while read -r FILE; do
        if [ -n "$FILE" ] && [[ "$FILE" =~ \.(yaml|yml)$ ]]; then
            echo "Initialise terraform for: $FILE"
            
            # Get the basename without extension (handles both .yaml and .yml)
            BASENAME=$(basename "$FILE")
            BASENAME="${BASENAME%.*}"
            TERRAFORM_DIR="$TERRAFORM_BASE_DIR/$BASENAME"
            
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