# Create DNS Zone for PostgreSQL
resource "azurerm_private_dns_zone" "postgres_dns" {
  name                = "privatelink.postgres.database.azure.com"
  resource_group_name = var.resource_group_name
}

# Here we create a link between the DNS zone and the VNet
# This allows the VNet to resolve the DNS names in the private DNS zone
resource "azurerm_private_dns_zone_virtual_network_link" "link" {
  name                  = "vnet-dns-link"
  resource_group_name   = var.resource_group_name
  private_dns_zone_name = azurerm_private_dns_zone.postgres_dns.name
  virtual_network_id    = var.vnet_id
}


# Create PostgreSQL Server
resource "azurerm_postgresql_flexible_server" "postgres" {
  name                          = "pg-flex-server"
  resource_group_name           = var.resource_group_name
  location                      = var.location
  version                       = "15"
  public_network_access_enabled = false

  delegated_subnet_id = var.postgres_subnet_id
  private_dns_zone_id = azurerm_private_dns_zone.postgres_dns.id

  administrator_login    = "pgadmin"
  administrator_password = "Brandon!"

  storage_mb   = 32768
  storage_tier = "P4"
  sku_name     = "GP_Standard_D2s_v3"
}


output "postgres_fqdn" {
  value = azurerm_postgresql_flexible_server.postgres.fqdn
}
