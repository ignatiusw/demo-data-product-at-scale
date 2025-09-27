# Variables for Databricks Terraform configuration
# These variables allow for environment-specific deployments

# Environment configuration
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
  description = "Name of the data product"
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

# Compute variables
# Currently not implemented due to Databricks Free Edition limitations

# Fake email domain variables for user creation
variable "email_domain" {
  description = "Email domain to use for user creation"
  type        = string
  default     = "@demo-data-product-at-scale.com"
}