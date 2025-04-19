terraform {
  backend "azurerm" {
    resource_group_name  = "rg-backend-1259"
    storage_account_name = "tfstate1259"
    container_name       = "tfstate"
    key                  = "terraform.tfstate"
  }
}
