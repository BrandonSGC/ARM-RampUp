# Create Resource Group
resource "azurerm_resource_group" "rg" {
  name     = "rg-terraform-infra"
  location = "Canada Central"
}

# Modules
module "network" {
  source              = "./modules/network"
  location            = var.location
  resource_group_name = var.resource_group_name
  depends_on          = [azurerm_resource_group.rg]
}

module "storage" {
  source                      = "./modules/storage"
  location                    = var.location
  resource_group_name         = var.resource_group_name
  private_endpoints_subnet_id = module.network.private_endpoints_subnet_id
  vnet_id                     = module.network.vnet_id
  depends_on                  = [azurerm_resource_group.rg]
}

module "database" {
  source              = "./modules/database"
  location            = var.location
  resource_group_name = var.resource_group_name
  vnet_id             = module.network.vnet_id
  postgres_subnet_id  = module.network.postgres_subnet_id
  depends_on          = [azurerm_resource_group.rg]
}

module "appservice" {
  source              = "./modules/appservice"
  location            = var.location
  resource_group_name = var.resource_group_name
  postgres_fqdn       = module.database.postgres_fqdn
  backend_subnet_id   = module.network.backend_subnet_id
  depends_on          = [azurerm_resource_group.rg]
}

module "staticwebapp" {
  source              = "./modules/staticwebapp"
  location            = var.location
  resource_group_name = var.resource_group_name
  depends_on          = [azurerm_resource_group.rg]
}

# TODO: Create a module for the Key Vault
