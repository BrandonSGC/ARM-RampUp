
# Create a Storage Account with a blob container for app service files
resource "azurerm_storage_account" "stg_account" {
  name                     = "stgappservicebgc"
  resource_group_name      = var.resource_group_name
  location                 = var.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
}

# Create a blob container in the storage account
resource "azurerm_storage_container" "app_service_container" {
  name                  = "appservicefiles"
  storage_account_id    = azurerm_storage_account.stg_account.id
  container_access_type = "private"
}

# Create a Private DNS Zone for the Storage Account
resource "azurerm_private_dns_zone" "storage_dns_zone" {
  name                = "privatelink.blob.core.windows.net"
  resource_group_name = var.resource_group_name
}

resource "azurerm_private_dns_zone_virtual_network_link" "storage_dns_vnet_link" {
  name                  = "storage-dns-vnet-link"
  resource_group_name   = var.resource_group_name
  private_dns_zone_name = azurerm_private_dns_zone.storage_dns_zone.name
  virtual_network_id    = var.vnet_id
}

# Create a Private Endpoint for the Storage Account
resource "azurerm_private_endpoint" "storage_private_endpoint" {
  name                = "pe-storage-account"
  location            = var.location
  resource_group_name = var.resource_group_name
  subnet_id           = var.private_endpoints_subnet_id

  private_service_connection {
    name                           = "storage-privatelink"
    private_connection_resource_id = azurerm_storage_account.stg_account.id
    is_manual_connection           = false
    subresource_names              = ["blob"] # or ["blob", "file"], depending on what you need
  }
}

