# Data sources for Databricks resources

# Get current workspaces
#data "databricks_mws_workspaces" "all" {
#  provider = databricks.account
#}

# Use the data source below to reference an existing catalog
# NOTE: This is a workaround due to Databricks Free Edition limitations, remove/comment if using a paid edition
data "databricks_catalog" "data_product_catalog" {
  name = local.catalog_name
}

# Get the SQL warehouse by name
data "databricks_sql_warehouse" "serverless_warehouse" {
  name = local.serverless_warehouse_name
}

# Specific resource to execute SQL statements on Databricks using the REST API
data "http" "execute_sql" {
  for_each = toset(local.sql_statements)

  url    = "${trimsuffix(var.databricks_host, "/")}/api/2.0/sql/statements/"
  method = "POST"

  request_headers = {
    Authorization = "Bearer ${var.databricks_token}"
    Content-Type  = "application/json"
  }

  request_body = jsonencode({
    statement    = each.value
    warehouse_id = data.databricks_sql_warehouse.serverless_warehouse.id
  })

  depends_on = [
    data.databricks_catalog.data_product_catalog, # remove data if using paid edition
    data.databricks_sql_warehouse.serverless_warehouse
  ]
}
