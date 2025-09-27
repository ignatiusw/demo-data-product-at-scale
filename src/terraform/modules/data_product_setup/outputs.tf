# Outputs for Data Product Setup Module
# These outputs can be used by calling modules or root configurations

# Catalog outputs
output "catalog_id" {
  description = "The ID of the created Databricks catalog"
  value       = data.databricks_catalog.data_product_catalog.id # remove data, if using paid edition
}

output "catalog_name" {
  description = "The name of the created Databricks catalog"
  value       = local.catalog_name
}

output "catalog_metastore_id" {
  description = "The metastore ID where the catalog was created"
  value       = data.databricks_catalog.data_product_catalog.catalog_info[0].metastore_id # remove data and catalog_info[0], if using paid edition
}

# Folder outputs
output "folder_path" {
  description = "The path of the created Databricks folder"
  value       = local.folder_name
}

# Group outputs
output "group_ids" {
  description = "The IDs of the created Databricks groups"
  value = {
    for key, group in databricks_group.data_product_groups :
    key => group.id
  }
}

output "group_display_names" {
  description = "The display names of the created Databricks groups"
  value = {
    for key, group in databricks_group.data_product_groups :
    key => group.display_name
  }
}

output "read_only_group_id" {
  description = "The ID of the read-only group"
  value       = databricks_group.data_product_groups["read-only"].id
}

output "modify_group_id" {
  description = "The ID of the modify group"
  value       = databricks_group.data_product_groups["modify"].id
}

# User outputs
output "read_only_user_ids" {
  description = "The IDs of the created read-only users"
  value = {
    for username, user in databricks_user.read_only_users :
    username => user.id
  }
}

output "modify_user_ids" {
  description = "The IDs of the created modify users"
  value = {
    for username, user in databricks_user.modify_users :
    username => user.id
  }
}

output "read_only_user_names" {
  description = "The usernames (emails) of the created read-only users"
  value = {
    for username, user in databricks_user.read_only_users :
    username => user.user_name
  }
}

output "modify_user_names" {
  description = "The usernames (emails) of the created modify users"
  value = {
    for username, user in databricks_user.modify_users :
    username => user.user_name
  }
}

# Service Principal outputs
output "service_principal_id" {
  description = "The ID of the created Databricks service principal"
  value       = databricks_service_principal.data_product_sp.id
}

output "service_principal_application_id" {
  description = "The application ID of the created Databricks service principal"
  value       = databricks_service_principal.data_product_sp.application_id
}

output "service_principal_display_name" {
  description = "The display name of the created Databricks service principal"
  value       = databricks_service_principal.data_product_sp.display_name
}

# Schema outputs
output "standard_schema_ids" {
  description = "The IDs of the created standard schemas"
  value = {
    for schema_name, schema in databricks_schema.standard_schemas :
    schema_name => schema.id
  }
}

output "standard_schema_names" {
  description = "The names of the created standard schemas"
  value = {
    for schema_name, schema in databricks_schema.standard_schemas :
    schema_name => schema.name
  }
}

output "standard_schema_full_names" {
  description = "The full names (catalog.schema) of the created standard schemas"
  value = {
    for schema_name, schema in databricks_schema.standard_schemas :
    schema_name => "${local.catalog_name}.${schema.name}"
  }
}

# Volume outputs
output "standard_volume_ids" {
  description = "The IDs of the created standard volumes"
  value = {
    for volume_name, volume in databricks_volume.standard_volumes :
    volume_name => volume.id
  }
}

output "standard_volume_names" {
  description = "The names of the created standard volumes"
  value = {
    for volume_name, volume in databricks_volume.standard_volumes :
    volume_name => volume.name
  }
}

# Group membership outputs
output "read_only_user_memberships" {
  description = "The IDs of the read-only user group memberships"
  value = {
    for username, membership in databricks_group_member.read_only_user_membership :
    username => membership.id
  }
}

output "modify_user_memberships" {
  description = "The IDs of the modify user group memberships"
  value = {
    for username, membership in databricks_group_member.modify_user_membership :
    username => membership.id
  }
}

output "service_principal_membership_id" {
  description = "The ID of the service principal group membership"
  value       = databricks_group_member.sp_membership.id
}

# Permissions outputs
output "catalog_permissions_id" {
  description = "The ID of the catalog permissions grant (combined read-only and modify)"
  value       = databricks_grants.catalog_permissions.id
}

# Convenience outputs for common use cases
output "catalog_fully_qualified_name" {
  description = "The fully qualified name of the catalog for use in SQL queries"
  value       = local.catalog_name
}

output "group_principal_names" {
  description = "The principal names of the groups for use in grants"
  value = {
    for key, group in databricks_group.data_product_groups :
    key => group.display_name
  }
}

output "read_only_user_principal_names" {
  description = "The principal names of the read-only users for use in grants"
  value = {
    for username, user in databricks_user.read_only_users :
    username => user.user_name
  }
}

output "modify_user_principal_names" {
  description = "The principal names of the modify users for use in grants"
  value = {
    for username, user in databricks_user.modify_users :
    username => user.user_name
  }
}

output "service_principal_principal_name" {
  description = "The principal name of the service principal for use in grants"
  value       = databricks_service_principal.data_product_sp.application_id
}

# Summary output for debugging/monitoring
output "data_product_setup_summary" {
  description = "Summary of all created resources"
  value = {
    catalog = {
      name         = local.catalog_name
      id           = data.databricks_catalog.data_product_catalog.id # remove data and catalog_info, if using paid edition
      metastore_id = data.databricks_catalog.data_product_catalog.catalog_info[0].metastore_id # remove data and catalog_info[0], if using paid edition
    }
    groups = {
      for key, group in databricks_group.data_product_groups :
      key => {
        name = group.display_name
        id   = group.id
      }
    }
    users = {
      read_only = {
        for username, user in databricks_user.read_only_users :
        username => {
          name = user.user_name
          id   = user.id
        }
      }
      modify = {
        for username, user in databricks_user.modify_users :
        username => {
          name = user.user_name
          id   = user.id
        }
      }
    }
    service_principal = {
      name           = databricks_service_principal.data_product_sp.display_name
      id             = databricks_service_principal.data_product_sp.id
      application_id = databricks_service_principal.data_product_sp.application_id
    }
    schemas = {
      for schema_name, schema in databricks_schema.standard_schemas :
      schema_name => {
        name      = schema.name
        full_name = "${local.catalog_name}.${schema.name}"
        id        = schema.id
      }
    }
    volumes = {
      for volume_name, volume in databricks_volume.standard_volumes :
      volume_name => {
        name      = volume.name
        full_name = "${local.catalog_name}.${volume.schema_name}.${volume.name}"
        id        = volume.id
      }
    }
    memberships = {
      read_only_users_count       = length(var.data_product_users["read-only"])
      modify_users_count          = length(var.data_product_users["modify"])
      service_principal_in_modify = true
      permissions_granted         = true
    }
  }
}