// =========== main.bicep ===========
//
targetScope = 'subscription'

// params
@description('Environment name used in all resource names')
param environ string

@description('Azure region (e.g. westeurope, westus3, etc.)')
param location string

@description('Admin Username')
param adminUsername string

@description('Admin SSH Key')
param adminSshKey string

@description('SSH Ip range whitelist')
param sshIpAddressRange string

@description('Resource group name')
param resourceGroupName string

// Create RG if not already existing
resource testRB 'Microsoft.Resources/resourceGroups@2021-01-01' = {
  name: resourceGroupName
  location: location
}

// Do Networking
module networking './networking.bicep' = {
  name: 'networking'
  scope: testRB
  params: {
    environ: environ
    location: location
    sshIpAddressRange: sshIpAddressRange
  }
}

// Do VM
module vm './vm.bicep' = {
  name: 'vm'
  scope: testRB
  params: {
    environ: environ
    location: location
    subnetId: networking.outputs.subnetId
    adminUsername: adminUsername
    adminSshKey: adminSshKey
  }
}

output vmPipIp string = vm.outputs.pipIp
