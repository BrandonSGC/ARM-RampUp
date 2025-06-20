/* The following code is a Bicep module that deploys a PowerShell script as a deployment script. 
It uses a user-assigned managed identity (already created) to authenticate and execute the script, 
which creates a new resource group. */

param name string
param location string
param identityResourceId string

resource deploymentScript 'Microsoft.Resources/deploymentScripts@2023-08-01' = {
  name: 'createRGScriptPS'
  location: location
  kind: 'AzurePowerShell'
  identity: {
    type: 'UserAssigned'
    userAssignedIdentities: {
      '${identityResourceId}': {}
    }
  }
  properties: {
    azPowerShellVersion: '10.0'
    arguments: '-rgName "${name}" -rgLocation "${location}"'
    // Path to the PowerShell script, we can also use text plane or use an external file using "primaryScriptUri" property insted of "scriptContent"
    scriptContent: loadTextContent('../scripts/CreateRG.ps1')
    cleanupPreference: 'OnSuccess' // controls whether the temporary container environment used to run the script is deleted. Options: 'OnSuccess' -> delete only if the script succeeds, 'Always' -> delete regardless the output, 'Never' -> never delete
    retentionInterval: 'PT1H' //  defines how long the execution container environment and logs are retained after the script finishes
  }
}

output result string = deploymentScript.properties.outputs.rgName
