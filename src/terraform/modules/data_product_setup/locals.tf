locals {
  # SQL Warehouse configuration
  serverless_warehouse_name = "Serverless Starter Warehouse"

  # Standardise catalog name: lowercase, replace non-alphanumeric with underscores, append environment
  catalog_name = "${replace(lower(var.data_product_name), "/[^a-zA-Z0-9]/", "_")}_${lower(var.environment)}"

  # Standardise folder name: replace non-alphanumeric with underscores, append environment
  folder_name = "/${replace(var.data_product_name, "/[^a-zA-Z0-9]/", "_")}_${lower(var.environment)}"

  # Create the service principal name
  service_principal_name = "${replace(var.data_product_name, "/[^a-zA-Z0-9]/", "_")}_${lower(var.environment)}_SP"

  # Create the group names
  group_names = {
    "read-only" = "${replace(var.data_product_name, "/[^a-zA-Z0-9]/", "_")}_${lower(var.environment)}_RO_Group"
    "modify"    = "${replace(var.data_product_name, "/[^a-zA-Z0-9]/", "_")}_${lower(var.environment)}_CRUD_Group"
  }

  # Standard privileges for groups
  volume_privileges = {
    "read-only" = ["BROWSE", "READ_FILES"]
    "modify"    = ["BROWSE", "READ_FILES", "WRITE_FILES"]
  }
  folder_privileges = {
    "read-only" = "CAN_READ"
    "modify"    = "CAN_MANAGE"
  }
  catalog_privileges = {
    "read-only" = ["USE_CATALOG", "USE_SCHEMA", "READ_VOLUME", "SELECT"]
    "modify"    = ["USE_CATALOG", "USE_SCHEMA", "READ_VOLUME", "SELECT", "APPLY_TAG", "EXECUTE", "MODIFY", "REFRESH", "WRITE_VOLUME", "CREATE_FUNCTION", "CREATE_MATERIALIZED_VIEW", "CREATE_SCHEMA", "CREATE_TABLE"]
  }

  # Format tags for Databricks SQL: ('tag1' = 'value1', 'tag2' = 'value2')
  formatted_tags = length(var.data_product_tags) > 0 ? "(${join(", ", [for k, v in var.data_product_tags : "'${replace(k, "'", "''")}' = '${replace(v, "'", "''")}'"])})" : ""

  # Filter and format tags for budget policy custom_tags: [{"division" = "abc"}, {"business unit" = "def"}]
  budget_policy_tags = [
    for key in ["division", "business unit"] : {
      "key"   = key
      "value" = lookup(var.data_product_tags, key, null)
    }
    if contains(keys(var.data_product_tags), key)
  ]

  # Standard SQL Statements
  sql_statements = concat(
    [
      "COMMENT ON CATALOG ${local.catalog_name} IS '${replace(var.data_product_description, "'", "''")}';", # Only required for Free Edition (Comment applied as part of resource creation in Paid Edition)
    ],
    length(var.data_product_tags) > 0 ? [
      "ALTER CATALOG ${local.catalog_name} SET TAGS ${local.formatted_tags};"
    ] : []
  )
}