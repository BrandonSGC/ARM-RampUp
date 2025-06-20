param location string

var subnetNames = [
  'web'
  'app'
  'db'
]

resource vnet 'Microsoft.Network/virtualNetworks@2024-05-01' = {
  name: 'vnet-${uniqueString(resourceGroup().id)}'
  location: location
  properties: {
    addressSpace: {
      addressPrefixes: [
        '10.0.0.0/16'
      ]
    }
    subnets: [
      for name in subnetNames: {
        name: name
        properties: {
          addressPrefix: '10.0.${indexOf(subnetNames, name)}.0/24'
        }
      }
    ]
  }
}
