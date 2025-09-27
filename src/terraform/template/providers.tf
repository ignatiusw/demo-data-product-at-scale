# Provider configuration for Databricks
# This file contains provider-specific configurations

provider "databricks" {
  # Use environment variable for DATABRICKS_HOST and DATABRICKS_TOKEN
}

provider "databricks" {
  alias      = "account"

  # Use the right Databricks account host based on your Databricks environment
  # Refer to https://registry.terraform.io/providers/databricks/databricks/latest/docs#host-argument
  host =  "https://accounts.cloud.databricks.com"
  # For account-level operations, use DATABRICKS_ACCOUNT_ID environment variable
}