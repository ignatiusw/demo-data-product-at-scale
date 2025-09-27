# Databricks Workspace Setup Module

This Terraform module creates and configures essential Databricks resources including a catalog, group, and user with appropriate permissions and memberships.

## Features

- ✅ Creates a Databricks catalog with configurable properties
- ✅ Creates a Databricks group
- ✅ Creates a Databricks user
- ✅ Creates a Databricks service principal (optional)
- ✅ Adds user to the group (optional)
- ✅ Adds service principal to the group (optional)
- ✅ Grants catalog permissions to the group (optional)
- ✅ Creates a default schema in the catalog
- ✅ Supports tagging and metadata
- ✅ Input validation for all variables
- ✅ Comprehensive outputs for integration

## Usage

### Basic Usage

```hcl
module "workspace_setup" {
  source = "./modules/databricks_workspace_setup"
  
  catalog_name    = "my_data_catalog"
  catalog_comment = "Main data catalog for analytics workloads"
  
  group_name = "data_engineers"
  user_email = "john.doe@company.com"
}
```

### Advanced Usage

```hcl
module "workspace_setup" {
  source = "./modules/databricks_workspace_setup"
  
  # Catalog configuration
  catalog_name         = "analytics_catalog"
  catalog_comment      = "Analytics catalog for data science team"
  catalog_storage_root = "abfss://analytics@mystorageaccount.dfs.core.windows.net/"
  catalog_isolation_mode = "ISOLATED"
  
  # Group configuration
  group_name         = "analytics_team"
  group_display_name = "Analytics Team"
  
  # User configuration
  user_email        = "data.scientist@company.com"
  user_display_name = "Data Scientist"
  user_force        = true
  
  # Service Principal configuration
  create_service_principal           = true
  service_principal_display_name     = "Analytics Service Principal"
  service_principal_application_id   = "12345678-1234-1234-1234-123456789abc"  # Optional: Use existing Azure AD app
  service_principal_force           = true
  service_principal_active          = true
  
  # Permissions and membership
  add_user_to_group                    = true
  add_service_principal_to_group       = true
  grant_group_catalog_permissions      = true
  catalog_privileges                   = ["USE_CATALOG", "CREATE_SCHEMA", "USE_SCHEMA"]
  
  # Tagging
  tags = {
    Environment = "production"
    Team        = "analytics"
    Project     = "data-platform"
  }
}
```

### Using Module Outputs

```hcl
# Reference outputs from the module
output "catalog_info" {
  value = {
    name      = module.workspace_setup.catalog_name
    id        = module.workspace_setup.catalog_id
    full_name = module.workspace_setup.catalog_fully_qualified_name
  }
}

# Use in other resources
resource "databricks_grants" "additional_permissions" {
  catalog = module.workspace_setup.catalog_name
  
  grant {
    principal  = "account users"
    privileges = ["USE_CATALOG"]
  }
}
```

## Requirements

| Name | Version |
|------|---------|
| terraform | >= 1.0 |
| databricks | >= 1.50 |

## Providers

| Name | Version |
|------|---------|
| databricks | >= 1.50 |

## Resources Created

| Resource | Type | Description |
|----------|------|-------------|
| `databricks_catalog.this` | Catalog | Main data catalog |
| `databricks_group.this` | Group | User group for permissions |
| `databricks_user.this` | User | Individual user account |
| `databricks_service_principal.this` | Service Principal | Service principal account (optional) |
| `databricks_schema.default` | Schema | Default schema in catalog |
| `databricks_group_member.user_to_group` | Membership | User-group membership |
| `databricks_group_member.service_principal_to_group` | Membership | Service principal-group membership |
| `databricks_grants.catalog_to_group` | Grants | Catalog permissions for group |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| catalog_name | Name of the Databricks catalog to create | `string` | n/a | yes |
| catalog_comment | Comment/description for the Databricks catalog | `string` | `""` | no |
| catalog_storage_root | Storage root path for the catalog | `string` | `null` | no |
| catalog_isolation_mode | Isolation mode for the catalog (ISOLATED or OPEN) | `string` | `"ISOLATED"` | no |
| group_name | Name of the Databricks group to create | `string` | n/a | yes |
| group_display_name | Display name for the Databricks group | `string` | `null` | no |
| user_email | Email address of the user to create | `string` | n/a | yes |
| user_display_name | Display name for the user | `string` | `null` | no |
| user_force | Force creation of user even if they already exist | `bool` | `false` | no |
| create_service_principal | Whether to create a service principal | `bool` | `true` | no |
| service_principal_display_name | Display name for the service principal | `string` | `null` | no |
| service_principal_application_id | Application ID for the service principal (if using existing Azure AD app) | `string` | `null` | no |
| service_principal_external_id | External ID for the service principal | `string` | `null` | no |
| service_principal_force | Force creation of service principal even if it already exists | `bool` | `false` | no |
| service_principal_active | Whether the service principal should be active | `bool` | `true` | no |
| add_user_to_group | Whether to add the created user to the created group | `bool` | `true` | no |
| add_service_principal_to_group | Whether to add the created service principal to the created group | `bool` | `true` | no |
| grant_group_catalog_permissions | Whether to grant the group permissions on the catalog | `bool` | `true` | no |
| catalog_privileges | List of privileges to grant the group on the catalog | `list(string)` | `["USE_CATALOG", "CREATE_SCHEMA"]` | no |
| tags | Tags to apply to resources | `map(string)` | `{}` | no |

### Available Catalog Privileges

- `ALL_PRIVILEGES` - All available privileges
- `USE_CATALOG` - Use the catalog
- `CREATE_SCHEMA` - Create schemas in the catalog
- `USE_SCHEMA` - Use schemas in the catalog
- `CREATE_TABLE` - Create tables in schemas
- `CREATE_VIEW` - Create views in schemas
- `CREATE_FUNCTION` - Create functions in schemas
- `CREATE_MODEL` - Create ML models in schemas

## Outputs

| Name | Description |
|------|-------------|
| catalog_id | The ID of the created Databricks catalog |
| catalog_name | The name of the created Databricks catalog |
| catalog_metastore_id | The metastore ID where the catalog was created |
| catalog_storage_root | The storage root of the created catalog |
| group_id | The ID of the created Databricks group |
| group_display_name | The display name of the created Databricks group |
| user_id | The ID of the created Databricks user |
| user_name | The username (email) of the created Databricks user |
| user_display_name | The display name of the created Databricks user |
| service_principal_id | The ID of the created Databricks service principal |
| service_principal_application_id | The application ID of the created Databricks service principal |
| service_principal_display_name | The display name of the created Databricks service principal |
| service_principal_external_id | The external ID of the created Databricks service principal |
| service_principal_group_membership_id | The ID of the service principal group membership |
| service_principal_principal_name | The principal name of the service principal for use in grants |
| default_schema_id | The ID of the default schema created in the catalog |
| default_schema_name | The name of the default schema created in the catalog |
| default_schema_full_name | The full name (catalog.schema) of the default schema |
| workspace_setup_summary | Summary of all created resources |

## Validation Rules

- **catalog_name**: Must contain only lowercase letters, numbers, and underscores
- **user_email**: Must be a valid email address format
- **catalog_isolation_mode**: Must be either "ISOLATED" or "OPEN"
- **catalog_privileges**: Must be valid Databricks catalog privileges

## Examples

### Multiple Environments

```hcl
# Development environment
module "dev_workspace" {
  source = "./modules/databricks_workspace_setup"
  
  catalog_name    = "dev_analytics"
  catalog_comment = "Development analytics catalog"
  group_name      = "dev_data_team"
  user_email      = "dev.user@company.com"
  
  tags = {
    Environment = "development"
  }
}

# Production environment
module "prod_workspace" {
  source = "./modules/databricks_workspace_setup"
  
  catalog_name    = "prod_analytics"
  catalog_comment = "Production analytics catalog"
  group_name      = "prod_data_team"
  user_email      = "prod.user@company.com"
  
  catalog_privileges = ["USE_CATALOG", "CREATE_SCHEMA", "USE_SCHEMA", "CREATE_TABLE"]
  
  tags = {
    Environment = "production"
  }
}
```

### Data Product Teams

```hcl
# Customer analytics team
module "customer_team_setup" {
  source = "./modules/databricks_workspace_setup"
  
  catalog_name    = "customer_analytics"
  catalog_comment = "Customer data and analytics catalog"
  group_name      = "customer_analytics_team"
  user_email      = "customer.analyst@company.com"
}

# Sales analytics team  
module "sales_team_setup" {
  source = "./modules/databricks_workspace_setup"
  
  catalog_name    = "sales_analytics"
  catalog_comment = "Sales data and analytics catalog"
  group_name      = "sales_analytics_team"
  user_email      = "sales.analyst@company.com"
}
```

## Notes

- The module creates a default schema named "default" in each catalog
- User display names default to the part before "@" in the email if not specified
- Group display names default to the group name if not specified
- All resources support tagging through the `tags` variable
- The module includes proper dependency management to ensure resources are created in the correct order
- Input validation prevents common configuration errors

## License

This module is provided as-is for demonstration purposes.