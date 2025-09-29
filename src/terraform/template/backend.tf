# Backend configuration for Terraform state
# This file configures where Terraform stores its state

terraform {
  backend "local" {
    path = "terraform.tfstate"
  }
}

# Alternative backend configurations for different environments:
# 
# For remote state (Azure Storage Account example):
# terraform {
#   backend "azurerm" {
#     resource_group_name  = ""
#     storage_account_name = ""
#     container_name       = ""
#     key                  = ""
#   }
# }
#
# For remote state (AWS S3 example):
# terraform {
#   backend "s3" {
#     bucket  = "" 
#     key     = ""
#     region  = ""
#     profile = ""
#   }
# }
