param name string
param location string
param storageAccountName string
param keyVaultUri string

resource plan 'Microsoft.Web/serverfarms@2023-01-01' = {
  name: '${name}-plan'
  location: location
  sku: {
    name: 'F1'
    tier: 'Free'
  }
  properties: {}
}

resource app 'Microsoft.Web/sites@2023-01-01' = {
  name: name
  location: location
  properties: {
    serverFarmId: plan.id
    siteConfig: {
      appSettings: [
        {
          name: 'STORAGE_ACCOUNT'
          value: storageAccountName
        }
        {
          name: 'KEYVAULT_URI'
          value: keyVaultUri
        }
      ]
    }
  }
}

output url string = 'https://${app.properties.defaultHostName}'
