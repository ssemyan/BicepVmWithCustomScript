// params
param environ string 
param location string
param sshIpAddressRange string

var vnetName = 'vnet-${environ}-${location}'
var nsgName = 'nsg-${environ}-${location}'
var vnetWebAddressRoot = '10.2'
var subnetName = 'default'

// Allow SSH for given IP address range and port 80 for all
resource nsg 'Microsoft.Network/networkSecurityGroups@2021-05-01' = {
  name: nsgName
  location: location
  properties: {
    securityRules: [
      {
        name: 'AllowSshInBound'
        properties: {
            protocol: 'Tcp'
            sourcePortRange: '*'
            destinationPortRange: '22'
            sourceAddressPrefix: sshIpAddressRange
            destinationAddressPrefix: '*'
            access: 'Allow'
            priority: 100
            direction: 'Inbound'
          }
        }
        {
          name: 'AllowHttpInBound'
          properties: {
              protocol: 'Tcp'
              sourcePortRange: '*'
              destinationPortRange: '80'
              sourceAddressPrefix: '*'
              destinationAddressPrefix: '*'
              access: 'Allow'
              priority: 110
              direction: 'Inbound'
            }
          }
        ]
    }   
}

resource virtualNetworkWeb 'Microsoft.Network/virtualNetworks@2020-08-01' = {
  name: vnetName
  location: location
  properties: {
    addressSpace: {
      addressPrefixes: [
        '${vnetWebAddressRoot}.0.0/16'
      ]
    }
    subnets: [
      {
        name: subnetName
        properties: {
          addressPrefix: '${vnetWebAddressRoot}.1.0/24'
          privateEndpointNetworkPolicies: 'Enabled'
          privateLinkServiceNetworkPolicies: 'Enabled'
          networkSecurityGroup: {
            id: nsg.id
          }
        }
      }
    ]
  }
}

output subnetId string = resourceId('Microsoft.Network/virtualNetworks/subnets', vnetName, subnetName)
