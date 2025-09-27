#!/bin/bash

# This script runs continuous integration (CI) tasks for the demo-data-product-at-scale project.

# Ensure the script exits on any error
set -e

echo "Running CI tasks for demo-data-product-at-scale..."

# Run tests to check data product uniqueness
echo "Checking data product name uniqueness..."
python -m pytest tests/test_data_product_uniqueness.py -v

echo "All CI tasks completed successfully!"