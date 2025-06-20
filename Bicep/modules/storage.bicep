// Parameters for the storage account module
param name string
param location string

// Resource definition for the storage account
resource storageAccount 'Microsoft.Storage/storageAccounts@2023-01-01' = {
  name: name
  location: location
  sku: {
    name: 'Standard_LRS'
  }
  kind: 'StorageV2'
  properties: {}
}


// Outptuts
output storageAccountName string = storageAccount.name
