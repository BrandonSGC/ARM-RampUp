@description('The name of the shared query.')
param queryName string = 'List virtual machines with their network interface and public IP'

@description('The Azure Resource Graph query to be saved to the shared query.')
param queryCode string = 'resources | where type =~ \'microsoft.compute/virtualmachines\' | extend nics=array_length(properties.networkProfile.networkInterfaces) | mv-expand nic=properties.networkProfile.networkInterfaces | where nics == 1 or nic.properties.primary =~ \'true\' or isempty(nic) | project vmId = id, vmName = name, vmSize=tostring(properties.hardwareProfile.vmSize), nicId = tostring(nic.id) | join kind=leftouter (resources | where type =~ \'microsoft.network/networkinterfaces\' | extend ipConfigsCount=array_length(properties.ipConfigurations) | mv-expand ipconfig=properties.ipConfigurations | where ipConfigsCount == 1 or ipconfig.properties.primary =~ \'true\' | project nicId = id, publicIpId = tostring(ipconfig.properties.publicIPAddress.id)) on nicId | project-away nicId1 | summarize by vmId, vmName, vmSize, nicId, publicIpId | join kind=leftouter (resources | where type =~ \'microsoft.network/publicipaddresses\' | project publicIpId = id, publicIpAddress = properties.ipAddress) on publicIpId | project-away publicIpId1'

@description('The description of the saved Azure Resource Graph query.')
param queryDescription string = 'This query uses two leftouter join commands to bring together virtual machines created with the Resource Manager deployment model, their related network interfaces, and any public IP address related to those network interfaces.'

resource query 'Microsoft.ResourceGraph/queries@2018-09-01-preview' = {
  name: queryName
  location: 'global'
  properties: {
    query: queryCode
    description: queryDescription
  }
}
