locals {
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
}