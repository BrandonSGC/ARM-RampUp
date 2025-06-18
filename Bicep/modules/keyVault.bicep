param vaultName string
param location string
@secure()
param secretValue string // Secret parameters should be marked as secure

resource keyVault 'Microsoft.KeyVault/vaults@2024-11-01' = {
  name: vaultName
  location: location
  properties: {
    tenantId: subscription().tenantId
    sku: {
      family: 'A'
      name: 'standard'
    }
    accessPolicies: []
    enabledForDeployment: true
  }
}

resource secret 'Microsoft.KeyVault/vaults/secrets@2024-11-01' = {
  parent: keyVault
  name: 'mySecret'
  properties: {
    value: secretValue
  }
}

output kvUri string = keyVault.properties.vaultUri
