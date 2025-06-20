// Imports
//import { generateUniqueKvName } from './utilities/utils.bicep'

// The target scope is set to 'resourceGroup' to deploy resources within a specific resource group.
targetScope = 'resourceGroup'

// Parameters
param location string = resourceGroup().location
param appName string = 'brandongcapp'
param deployPowerShellScript bool = true
param deployBashScript bool = false

module storage './modules/storage.bicep' = {
  name: 'storageModule'
  params: {
    name: '${appName}storage'
    location: location
  }
}

// module keyvault './modules/keyvault.bicep' = {
//   name: 'kvModule'
//   params: {
//     vaultName: generateUniqueKvName('bgkv')
//     location: location
//     secretValue: 'SuperSecret123'
//   }
// }

// Reference an already created keyvault.
resource keyvault 'Microsoft.KeyVault/vaults@2024-12-01-preview' existing = {
  name: 'personalkeyvaultbgc'
  scope: resourceGroup('MyResources')
}

// Create a virtual network and some subnets.
module network './modules/network.bicep' = {
  name: 'vnetModule'
  params: {
    location: location
  }
}

// Deploys a web app.
module web './modules/webApp.bicep' = {
  name: 'webAppModule'
  params: {
    name: '${appName}-web'
    location: location
    storageAccountName: storage.outputs.storageAccountName
    keyVaultUri: keyvault.properties.vaultUri
  }
}

// Deploys a deployment script with PowerShell depending on a conditional parameter
module deploymentScriptPS 'modules/deplScriptPS.bicep' = if (deployPowerShellScript) {
  name: 'deploymentScriptPSModule'
  params: {
    name: 'rg-deployment-script-ps'
    location: location
    identityResourceId: '/subscriptions/16e28336-0da6-4238-bf6c-6f3ee682a721/resourcegroups/MyResources/providers/Microsoft.ManagedIdentity/userAssignedIdentities/managedidentitybgc'
  }
}

// Deploys a deployment script with Azure CLI depending on a conditional parameter
module deploymentScriptBS 'modules/deplScriptBS.bicep' = if (deployBashScript) {
  name: 'deploymentScriptBSModule'
  params: {
    name: 'rg-deployment-script-bs'
    location: location
    identityResourceId: '/subscriptions/16e28336-0da6-4238-bf6c-6f3ee682a721/resourcegroups/MyResources/providers/Microsoft.ManagedIdentity/userAssignedIdentities/managedidentitybgc'
  }
}

// Deploy multiple instances by using a loop using storage accounts.
module storageInstance './modules/storage.bicep' = [
  for i in range(0, 3): {
    name: 'storageInstance${i}'
    params: {
      name: '${appName}storage${i}'
      location: location
    }
  }
]

// WebApp outputs
output appUrl string = web.outputs.url

// Stroage account outputs
output storageAccountName string = storage.outputs.storageAccountName

// Keyvault outputs
output keyvault string = keyvault.properties.vaultUri

// Deployment scripts outputs
output deploymentScriptPSResult string = deploymentScriptPS.outputs.result
