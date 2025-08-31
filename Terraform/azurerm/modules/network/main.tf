# Create VNet
resource "azurerm_virtual_network" "vnet" {
  name                = "vnet-infra"
  location            = var.location
  resource_group_name = var.resource_group_name
  address_space       = ["10.0.0.0/16"]
}

# Create backend subnet
resource "azurerm_subnet" "backend_subnet" {
  name                 = "backend-subnet"
  resource_group_name  = var.resource_group_name
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
  resource_group_name  = var.resource_group_name
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

# Create private endpoint subnet
resource "azurerm_subnet" "private_endpoints_subnet" {
  name                 = "private-endpoints-subnet"
  resource_group_name  = var.resource_group_name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = ["10.0.3.0/24"]
}


# Outputs
output "backend_subnet_id" {
  value = azurerm_subnet.backend_subnet.id
}

output "postgres_subnet_id" {
  value = azurerm_subnet.postgres_subnet.id
}

output "private_endpoints_subnet_id" {
  value = azurerm_subnet.private_endpoints_subnet.id
}

output "vnet_id" {
  value = azurerm_virtual_network.vnet.id
}
