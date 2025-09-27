# Variables for Databricks Workspace Setup Module
# This module creates a catalog, group, and user in Databricks

# Environment variables
variable "environment" {
  description = "Environment name (dev, test, prod)"
  type        = string
  default     = "dev"
  
  validation {
    condition     = contains(["dev", "test", "prod"], var.environment)
    error_message = "Environment must be one of: dev, staging, prod."
  }
}

# Data product variables
variable "data_product_name" {
  description = "Name of the data product to create"
  type        = string
}

variable "data_product_description" {
  description = "Description of the data product"
  type        = string
  default     = ""
}

variable "data_product_tags" {
  description = "Tags to apply to the data product"
  type        = map(string)
  default     = {}
}

# User variables
variable "data_product_users" {
  description = "Users to add to the data product"
  type        = map(list(string))
  default = {
    "read-only" = []
    "modify" = []
  }
}

# Standard schemas & volumes for a catalog
variable "standard_schemas" {
  description = "List of standard schemas to create in the catalog"
  type        = list(string)
  default     = ["raw", "bronze", "silver", "gold", "staging", "config", "custom"]
}

# Standard volumes for a catalog
variable "standard_volumes" {
  description = "List of standard volumes to create in the raw schema of the catalog"
  type        = list(string)
  default     = ["landing", "upload", "archive"]
}

# Compute variables
# Currently not implemented due to Databricks Free Edition limitations

# Fake email domain variables for user creation
variable "email_domain" {
  description = "Email domain to use for user creation"
  type        = string
  default     = "@demo-data-product-at-scale.com"
}