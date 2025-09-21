# Terraform Databricks Configuration

This directory contains Terraform configuration files to manage Databricks resources using the Databricks provider with local state management.

## Files Overview

- `main.tf` - Main Terraform configuration with required providers and example resources
- `providers.tf` - Databricks provider configuration with authentication options
- `variables.tf` - Variable definitions for environment-specific deployments
- `backend.tf` - Backend configuration for local state management
- `terraform.tfvars.example` - Example variables file for development environment
- `prod.tfvars.example` - Example variables file for production environment

## Quick Start

1. **Initialize Terraform**
   ```bash
   cd src/terraform
   terraform init
   ```

2. **Configure Variables**
   ```bash
   # Copy example file and update with your values
   cp terraform.tfvars.example terraform.tfvars
   
   # Edit terraform.tfvars with your Databricks workspace details
   vim terraform.tfvars
   ```

3. **Plan and Apply**
   ```bash
   # Review planned changes
   terraform plan
   
   # Apply changes
   terraform apply
   ```

## Environment-Specific Deployments

For different environments, use specific variable files:

```bash
# Development
terraform plan -var-file="terraform.tfvars"
terraform apply -var-file="terraform.tfvars"

# Production
terraform plan -var-file="prod.tfvars"
terraform apply -var-file="prod.tfvars"
```

## Required Variables

Before running Terraform, you must provide:

- `databricks_host` - Your Databricks workspace URL
- `databricks_token` - Your Databricks personal access token

Optional variables:
- `databricks_account_id` - Required only for account-level resources
- `environment` - Environment name (defaults to "dev")
- `project_name` - Project identifier for resource naming

## Authentication Methods

The configuration supports multiple authentication methods:

1. **Personal Access Token** (default, configured in providers.tf)
2. **Azure CLI** (for Azure-hosted Databricks)
3. **Azure Service Principal** 
4. **Username/Password** (not recommended for production)

Uncomment the appropriate provider block in `providers.tf` based on your authentication method.

## State Management

This configuration uses local state files by default. The state file will be created as `terraform.tfstate` in the current directory.

For production use, consider using remote state backends like:
- Azure Storage Account
- AWS S3
- Terraform Cloud

Examples are provided in `backend.tf`.

## Security Notes

- Never commit `terraform.tfvars` files containing sensitive information
- Use environment variables or secure secret management for tokens
- The `.gitignore` file excludes sensitive files from version control

## Next Steps

After initialization, you can:
1. Add Databricks resources to `main.tf`
2. Create modules for reusable components
3. Set up CI/CD pipelines for automated deployments
4. Configure remote state for team collaboration