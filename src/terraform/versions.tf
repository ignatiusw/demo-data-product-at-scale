# Main Terraform configuration
# This file contains the root module configuration

terraform {
  required_version = "~> 1.13.0"

  required_providers {
    databricks = {
      source  = "databricks/databricks"
      version = "~> 1.88" # Latest stable version as of 1 September 2025
    }
    http = {
      source  = "hashicorp/http"
      version = "~> 3.5" # Latest stable version as of 1 September 2025
    }
  }
}