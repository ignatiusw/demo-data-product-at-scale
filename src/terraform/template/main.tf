module "data_product_setup" {
  source = "../../modules/data_product_setup"
  
  providers = {
      databricks         = databricks
      databricks.account = databricks.account
  }

  environment = var.environment

  databricks_host  = var.databricks_host
  databricks_token = var.databricks_token

  data_product_name        = var.data_product_name
  data_product_description = var.data_product_description
  data_product_tags        = var.data_product_tags
  
  data_product_users       = var.data_product_users

  email_domain             = var.email_domain
}