#!/bin/bash

# This script sets up the environment for the demo-data-product-at-scale project.
# It installs necessary tools and dependencies including Homebrew, Databricks CLI,
# pyenv, Python 3.13.7, GNU Make, tfenv, and Terraform 1.13.0.
# It also creates and activates a Python virtual environment and installs required Python packages.

# Ensure the script exits on any error
# set -e

# Install Homebrew if not already installed
if ! command -v brew &> /dev/null
then
    echo "Homebrew not found. Installing Homebrew..."
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
else
    echo "Homebrew is already installed."
fi

# Update Homebrew to ensure we have the latest package definitions
brew update

# Tap the Databricks Homebrew repository and install the Databricks CLI
brew tap databricks/tap
brew install databricks

# Configure the Databricks CLI with your workspace URL and token if DEFAULT profile is not set
if ! databricks auth profiles | tail -n +2 | grep -q "^DEFAULT[[:space:]]"; then
    echo "Configuring Databricks CLI for DEFAULT profile..."
    # You will be prompted to enter these details
    databricks configure --profile DEFAULT
else
    echo "Databricks CLI DEFAULT profile is already configured."
fi

# Install pyenv and Python 3.13.7
brew install pyenv
pyenv install -s 3.13.7
brew install pyenv-virtualenv

# Install GNU Make
brew install make

# Install tfenv and Terraform 1.13.0
brew install tfenv
tfenv install 1.13.0
tfenv use 1.13.0

# Initialize pyenv and pyenv-virtualenv
eval "$(pyenv init -)"
eval "$(pyenv virtualenv-init -)"

# Create and activate the virtual environment and install dependencies
pyenv virtualenv 3.13.7 demo-data-product-at-scale
pyenv activate demo-data-product-at-scale
pip install -r ./scripts/requirements.txt

# Print instructions to activate the environment in future shell sessions, uncomment if needed
# echo ""
# echo "==================================================================="
# echo "IMPORTANT: To activate the Python environment in your current shell,"
# echo "please run one of the following commands:"
# echo ""
# echo "  eval \"\$(pyenv init -)\" && eval \"\$(pyenv virtualenv-init -)\" && pyenv activate demo-data-product-at-scale"
# echo ""
# echo "OR for future runs, source this script instead:"
# echo "  source ./scripts/init.sh"
# echo "==================================================================="