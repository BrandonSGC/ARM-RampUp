# Create a Static Web App to host the ReactJS frontend
resource "azurerm_static_web_app" "static_web_app" {
  name                = "webapp-terraform-infra"
  resource_group_name = var.resource_group_name
  location            = "East US 2"
  sku_tier            = "Free"
  sku_size            = "Free"
}
