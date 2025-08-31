# Create App Service plan for the NodeJS API
resource "azurerm_service_plan" "app_service_plan" {
  name                = "service-plan-terraform-infra"
  resource_group_name = var.resource_group_name
  location            = var.location
  os_type             = "Linux"
  sku_name            = "P1v2" # Premium V2 SKU supporting VNet Integration
}

# Create WebApp for the NodeJS API
resource "azurerm_linux_web_app" "app_service_web_app" {
  name                = "webapplxbgcinfra"
  resource_group_name = var.resource_group_name
  location            = azurerm_service_plan.app_service_plan.location
  service_plan_id     = azurerm_service_plan.app_service_plan.id
  depends_on          = [azurerm_service_plan.app_service_plan]

  site_config {
    application_stack {
      node_version = "22-lts"
    }
  }

  app_settings = {
    DATABASE_URL = "postgresql://pgadmin:Brandon!${var.postgres_fqdn}:5432/postgres"
  }
}

# Vnet Integration for the App Service
resource "azurerm_app_service_virtual_network_swift_connection" "appservice_vnet_integration" {
  app_service_id = azurerm_linux_web_app.app_service_web_app.id
  subnet_id      = var.backend_subnet_id
}
