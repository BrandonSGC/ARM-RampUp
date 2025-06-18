// TODO: Add imports from another file, could be functions, variables, or modules...

// The target scope is set to 'resourceGroup' to deploy resources within a specific resource group.
targetScope = 'resourceGroup'

// Parameters
param location string = resourceGroup().location
param environment string = 'dev'
param appName string = 'brandongcapp'
param enableMonitoring bool = true

module storage './modules/storage.bicep' = {
  name: 'storageModule'
  params: {
    name: '${appName}storage'
    location: location
  }
}

module keyvault './modules/keyvault.bicep' = {
  name: 'kvModule'
  params: {
    vaultName: '${appName}-kv'
    location: location
    secretValue: 'SuperSecret123'
  }
}

module network './modules/network.bicep' = {
  name: 'vnetModule'
  params: {
    location: location
  }
}

module web './modules/webApp.bicep' = {
  name: 'webAppModule'
  params: {
    name: '${appName}-web'
    location: location
    storageAccountName: storage.outputs.storageAccountName
    keyVaultUri: keyvault.outputs.kvUri
  }
}

// TODO: Deploy a module based on a condition

// TODO: Deploy multiple instances by using a loop

// TODO: Get the output from some property in a resource


// Outputs
output appUrl string = web.outputs.url
