# Create Resource Group
resource "azurerm_resource_group" "rg" {
  name     = "rg-terraform-infra"
  location = "Canada Central"

}

# Create VNet
resource "azurerm_virtual_network" "vnet" {
  name                = "vnet-infra"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  address_space       = ["10.0.0.0/16"]
}

# Create backend subnet
resource "azurerm_subnet" "backend_subnet" {
  name                 = "backend-subnet"
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = ["10.0.1.0/24"]
  delegation {
    name = "appsvc"
    service_delegation {
      name    = "Microsoft.Web/serverFarms"
      actions = ["Microsoft.Network/virtualNetworks/subnets/action"]
    }
  }
}

# Create subnet for postgresql
resource "azurerm_subnet" "postgres_subnet" {
  name                 = "postgres-subnet"
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = ["10.0.2.0/24"]

  delegation {
    name = "psql-delegation"
    service_delegation {
      name = "Microsoft.DBforPostgreSQL/flexibleServers"
      actions = [
        "Microsoft.Network/virtualNetworks/subnets/action"
      ]
    }
  }
}


# Create DNS Zone for PostgreSQL
resource "azurerm_private_dns_zone" "postgres_dns" {
  name                = "privatelink.postgres.database.azure.com"
  resource_group_name = azurerm_resource_group.rg.name
}

resource "azurerm_private_dns_zone_virtual_network_link" "link" {
  name                  = "vnet-dns-link"
  resource_group_name   = azurerm_resource_group.rg.name
  private_dns_zone_name = azurerm_private_dns_zone.postgres_dns.name
  virtual_network_id    = azurerm_virtual_network.vnet.id
}


# Create PostgreSQL Server
resource "azurerm_postgresql_flexible_server" "postgres" {
  name                          = "pg-flex-server"
  resource_group_name           = azurerm_resource_group.rg.name
  location                      = azurerm_resource_group.rg.location
  version                       = "15"
  public_network_access_enabled = false

  delegated_subnet_id = azurerm_subnet.postgres_subnet.id
  private_dns_zone_id = azurerm_private_dns_zone.postgres_dns.id

  administrator_login    = "pgadmin"
  administrator_password = "Brandon!"

  storage_mb   = 32768
  storage_tier = "P4"
  sku_name     = "GP_Standard_D2s_v3"
}

# Create App Service plan for the NodeJS API
resource "azurerm_service_plan" "app_service_plan" {
  name                = "service-plan-terraform-infra"
  resource_group_name = azurerm_resource_group.rg.name
  location            = "East US 2"
  os_type             = "Linux"
  sku_name            = "B1"
}

# Create WebApp for the NodeJS API
resource "azurerm_linux_web_app" "app_service_web_app" {
  name                = "webapplxbgcinfra"
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_service_plan.app_service_plan.location
  service_plan_id     = azurerm_service_plan.app_service_plan.id
  depends_on          = [azurerm_service_plan.app_service_plan]

  site_config {
    application_stack {
      node_version = "22-lts"
    }
  }

  # TODO: Findout what this is...
  app_settings = {
    DATABASE_URL = "postgresql://pgadmin:Brandon!${azurerm_postgresql_flexible_server.postgres.fqdn}:5432/postgres"
  }
}


# Create a Static Web App to host the ReactJS frontend
resource "azurerm_static_web_app" "static_web_app" {
  name                = "webapp-terraform-infra"
  resource_group_name = azurerm_resource_group.rg.name
  location            = "East US 2"
  sku_tier            = "Free"
  sku_size            = "Free"
}
