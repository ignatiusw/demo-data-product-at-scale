#!/bin/bash

# Prompt user for their Databricks' host URL
read -p "Enter your Databricks host URL: " DATABRICKS_HOST

# Prompt user for their Databricks' token (input hidden for security)
read -s -p "Enter your Databricks token: " DATABRICKS_TOKEN
echo ""  # just to add a new line after password input

# Prompt user for their Databricks account ID
read -p "Enter your Databricks account ID (for account-level operations): " DATABRICKS_ACCOUNT_ID

# Set environment variables
export DATABRICKS_HOST="$DATABRICKS_HOST"
export DATABRICKS_TOKEN="$DATABRICKS_TOKEN"
export DATABRICKS_ACCOUNT_ID="$DATABRICKS_ACCOUNT_ID"

# Show that they are set (don’t usually print passwords in real scripts!)
echo "Databricks host is set to: $DATABRICKS_HOST"
echo "Databricks token has been captured and stored in DATABRICKS_TOKEN (not displayed)"
echo "Databricks account ID is set to: $DATABRICKS_ACCOUNT_ID"
echo "Environment variables have been set. You can now run Terraform commands."