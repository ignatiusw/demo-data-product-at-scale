# Data Product Setup Module - Main Resources
# Creates a data product with catalog, folder, groups, users, schemas, volumes and assign memberships and privileges

### 1. Create Databricks Objects ###

# Create Databricks Catalog
# NOTE: Commented out due to Databricks Free Edition limitations, uncomment if using a paid edition
# resource "databricks_catalog" "data_product_catalog" {
#   name          = local.catalog_name
#   comment       = var.data_product_description != "" ? var.data_product_description : "Catalog for ${var.data_product_name}"
#   
#   # Apply tags if provided
#   properties = {
#     for tag_key, tag_value in var.data_product_tags : tag_key => tag_value
#   }
# }

# Comment out the above resource and use the data source below to reference an existing catalog
# NOTE: This is a workaround due to Databricks Free Edition limitations, remove if using a paid edition
data "databricks_catalog" "data_product_catalog" {
    name = local.catalog_name
}

# Create Databricks Groups
# NOTE: In Free Edition, groups can only be created at workspace level, not at Unity Catalog level
# Therefore, these groups cannot be added to the catalog privileges directly
resource "databricks_group" "data_product_groups" {
  for_each = local.group_names
  
  display_name          = each.value
  workspace_access      = true
  databricks_sql_access = true
}

# Create Service Principal
resource "databricks_service_principal" "data_product_sp" {
  display_name = local.service_principal_name
}

# Create standard schemas in the catalog
resource "databricks_schema" "standard_schemas" {
  for_each = toset(var.standard_schemas)
  
  catalog_name = local.catalog_name
  name         = each.value
  comment      = "Standard ${each.value} schema for ${var.data_product_name}"
  
  properties = {
    for tag_key, tag_value in var.data_product_tags : tag_key => tag_value
  }
  
  # depends_on = [databricks_catalog.data_product_catalog] # remove the comment if using paid edition
}

# Create standard volumes in the raw schema of the catalog
resource "databricks_volume" "standard_volumes" {
  for_each = toset(var.standard_volumes)

  catalog_name = local.catalog_name
  schema_name  = databricks_schema.standard_schemas["raw"].name
  name         = each.value
  comment      = "Standard ${each.value} volume for ${var.data_product_name}"
  volume_type  = "MANAGED" # Or use EXTERNAL if there is no limitation on the Free Edition
  
  depends_on = [
    #databricks_catalog.data_product_catalog, # remove the comment if using paid edition
    databricks_schema.standard_schemas["raw"]
  ]
}

# Create workspace directory for the data product (optional)
resource "databricks_directory" "data_product_directory" {
  path = local.folder_name
}

### 2. Create Users ###

# Create users for read-only group
resource "databricks_user" "read_only_users" {
  for_each = toset(var.data_product_users["read-only"])

  user_name    = "${replace(each.value, "/[^a-zA-Z0-9]/", ".")}${var.email_domain}"
  display_name = each.value
  force        = true
}

# Create users for modify group  
resource "databricks_user" "modify_users" {
  for_each = toset(var.data_product_users["modify"])
  
  user_name    = "${replace(each.value, "/[^a-zA-Z0-9]/", ".")}${var.email_domain}"
  display_name = each.value
  force        = true
}

### 3. Assign Privileges ###

# Grant catalog permissions to read-only group
# NOTE: In Free Edition, groups cannot be granted catalog privileges directly, uncomment this block if using a paid edition
# resource "databricks_grants" "catalog_permissions" {
#   catalog = local.catalog_name
#   
#   grant {
#     principal  = databricks_service_principal.data_product_sp.application_id
#     privileges = local.catalog_privileges["read-only"]
#   }
#   
#   grant {
#     principal  = databricks_service_principal.data_product_sp.application_id
#     privileges = local.catalog_privileges["modify"]
#   }
#   
#   depends_on = [
#     databricks_catalog.data_product_catalog,
#     databricks_group.data_product_groups
#   ]
# }

# Grant catalog permissions to all users and service principal
# NOTE: All catalog permissions must be managed in a single databricks_grants resource to avoid conflicts
resource "databricks_grants" "catalog_permissions" {
  catalog = local.catalog_name
  
  # Grant read-only permissions to read-only users
  dynamic "grant" {
    for_each = toset(var.data_product_users["read-only"])
    content {
      principal  = databricks_user.read_only_users[grant.value].user_name
      privileges = local.catalog_privileges["read-only"]
    }
  }
  
  # Grant modify permissions to modify users
  dynamic "grant" {
    for_each = toset(var.data_product_users["modify"])
    content {
      principal  = databricks_user.modify_users[grant.value].user_name
      privileges = local.catalog_privileges["modify"]
    }
  }
  
  # Grant modify permissions to service principal
  grant {
    principal  = databricks_service_principal.data_product_sp.application_id
    privileges = local.catalog_privileges["modify"]
  }
  
  depends_on = [
    databricks_user.read_only_users,
    databricks_user.modify_users,
    databricks_service_principal.data_product_sp
  ]
}

# Grant directory permissions to groups
resource "databricks_permissions" "directory_permissions" {
  directory_path = databricks_directory.data_product_directory.path
  
  dynamic "access_control" {
    for_each = local.folder_privileges
    content {
      group_name       = databricks_group.data_product_groups[access_control.key].display_name
      permission_level = access_control.value
    }
  }
  
  depends_on = [
    databricks_group.data_product_groups,
    databricks_directory.data_product_directory
  ]
}

### 4. Assign Memberships ###

# Add read-only users to read-only group
resource "databricks_group_member" "read_only_user_membership" {
  for_each = toset(var.data_product_users["read-only"])
  
  group_id  = databricks_group.data_product_groups["read-only"].id
  member_id = databricks_user.read_only_users[each.value].id
  
  depends_on = [
    databricks_group.data_product_groups["read-only"],
    databricks_user.read_only_users
  ]
}

# Add modify users to modify group
resource "databricks_group_member" "modify_user_membership" {
  for_each = toset(var.data_product_users["modify"])
  
  group_id  = databricks_group.data_product_groups["modify"].id
  member_id = databricks_user.modify_users[each.value].id
  
  depends_on = [
    databricks_group.data_product_groups["modify"],
    databricks_user.modify_users
  ]
}

# Add service principal to modify group
resource "databricks_group_member" "sp_membership" {
  group_id  = databricks_group.data_product_groups["modify"].id
  member_id = databricks_service_principal.data_product_sp.id
  
  depends_on = [
    databricks_group.data_product_groups["modify"],
    databricks_service_principal.data_product_sp
  ]
}