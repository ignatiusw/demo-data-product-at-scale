# Variables for Databricks Terraform configuration
# These variables allow for environment-specific deployments

# Databricks workspace configuration
variable "databricks_host" {
  description = "Databricks workspace URL"
  type        = string
}

variable "databricks_token" {
  description = "Databricks personal access token"
  type        = string
  sensitive   = true
}

variable "databricks_account_id" {
  description = "Databricks account ID (required for account-level resources)"
  type        = string
  default     = null
}

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

variable "project_name" {
  description = "Name of the project for resource naming"
  type        = string
  default     = "demo-data-product"
}

# Resource naming configuration
variable "resource_prefix" {
  description = "Prefix for resource names"
  type        = string
  default     = ""
}

variable "tags" {
  description = "Common tags to apply to resources"
  type        = map(string)
  default = {
    Project     = "demo-data-product-at-scale"
    Environment = "dev"
    ManagedBy   = "terraform"
  }
}

# Databricks cluster configuration (optional)
variable "cluster_name" {
  description = "Name for the Databricks cluster"
  type        = string
  default     = null
}

variable "cluster_spark_version" {
  description = "Spark version for Databricks cluster"
  type        = string
  default     = "13.3.x-scala2.12"
}

variable "cluster_node_type" {
  description = "Node type for Databricks cluster"
  type        = string
  default     = "i3.xlarge"
}

variable "cluster_num_workers" {
  description = "Number of workers for Databricks cluster"
  type        = number
  default     = 1
}

# Notebook configuration (optional)
variable "notebook_path_prefix" {
  description = "Prefix for notebook paths in Databricks workspace"
  type        = string
  default     = "/Shared"
}