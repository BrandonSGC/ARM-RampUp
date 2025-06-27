param name string
param location string
param identityResourceId string

resource deploymentScript 'Microsoft.Resources/deploymentScripts@2023-08-01' = {
  name: 'createRGScriptCLI'
  location: location
  kind: 'AzureCLI'
  identity: {
    type: 'UserAssigned'
    userAssignedIdentities: {
      '${identityResourceId}': {}
    }
  }
  properties: {
    azCliVersion: '2.53.0'
    arguments: '${name} ${location}'
    scriptContent: '''
      rgName=$1
      rgLocation=$2

      echo "Creating resource group: $rgName in $rgLocation"
      az group create --name "$rgName" --location "$rgLocation"

      echo "rgName=$rgName" >> $AZ_SCRIPTS_OUTPUT_PATH
    '''
    cleanupPreference: 'OnSuccess'
    retentionInterval: 'PT1H'
  }
}

output result string = deploymentScript.properties.outputs.rgName
