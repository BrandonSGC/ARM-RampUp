## 🔍 Difference Between `azurerm` and `azapi` Terraform Providers

### ✅ `azurerm` – Azure Resource Manager Provider

The `azurerm` provider is the **primary and most commonly used Terraform provider for Azure**. It provides **high-level resource blocks** for creating and managing Azure infrastructure in a readable and strongly-typed way.

- **Uses**: Virtual Machines, VNets, Storage Accounts, Key Vaults, AKS, App Services, etc.
- **Stability**: Mature, well-documented, and widely adopted.
- **Ease of Use**: Very user-friendly and resource-centric.
- **Limitations**:
  - **Lags behind** when new Azure services or features are released.
  - Sometimes it can take weeks or months before new resource types or properties become available.

> Example:

```hcl
resource "azurerm_storage_account" "example" {
  name                     = "mystorageaccount"
  resource_group_name      = azurerm_resource_group.example.name
  location                 = azurerm_resource_group.example.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
}


Why having multiple subnets in the VNet?

![Project Architecture](image-1.png)
```
