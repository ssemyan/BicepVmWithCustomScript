// params
param environ string
param location string

@description('IDs of the subnet the VM should run in')
param subnetId string

@description('Admin username')
param adminUsername string

@description('Admin ssh key')
param adminSshKey string

var vmName = 'vm-${environ}-${location}-001'
var publicIpName = 'pip-${environ}-${location}-001'
var nicName = 'nic-${environ}-${location}-001'

// Size of the VM
var vmSize = 'Standard_D2s_v3'

resource pip 'Microsoft.Network/publicIPAddresses@2021-02-01' = {
  name: publicIpName
  location: location
  sku: {
    name: 'Standard'
    tier: 'Regional'
  }
  properties: {
    publicIPAllocationMethod: 'Static'
  }
}

resource nic 'Microsoft.Network/networkInterfaces@2021-02-01' = {
  name: nicName
  location: location
  properties: {
    ipConfigurations: [
      {
        name: 'ipconfig1'
        properties: {
          privateIPAllocationMethod: 'Dynamic'
          publicIPAddress: {
            id: pip.id
          }
          subnet: {
            id: subnetId
          }
        }
      }
    ]
  }
}

resource vm 'Microsoft.Compute/virtualMachines@2021-03-01' = {
  name: vmName
  location: location
  properties: {
    hardwareProfile: {
      vmSize: vmSize
    }
    osProfile: {
      computerName: vmName
      adminUsername: adminUsername
      linuxConfiguration: {
        disablePasswordAuthentication: true
        ssh: {
          publicKeys: [
            {
              path: '/home/${adminUsername}/.ssh/authorized_keys'
              keyData: adminSshKey
            }
          ]
        }
      }
    }
    storageProfile: {
      imageReference: {
        publisher: 'Canonical'
        offer: 'UbuntuServer'
        sku: '18.04-LTS'
        version: 'latest'
      }
      osDisk: {
        createOption: 'FromImage'
        managedDisk: {
          storageAccountType: 'Premium_LRS'
        }
        deleteOption: 'Delete'
      }
    }
    networkProfile: {
      networkInterfaces: [
        {
          id: nic.id
          properties:{
            deleteOption: 'Delete'
          }
        }
      ]
    }
    diagnosticsProfile: {
      bootDiagnostics: {
        enabled: true
      }
    }
  }
}

resource extension 'Microsoft.Compute/virtualMachines/extensions@2021-11-01' = {
  parent: vm
  name:'config-app'
  location:location
  properties:{
    publisher: 'Microsoft.Azure.Extensions'
    type:'CustomScript'
    typeHandlerVersion: '2.1'
    autoUpgradeMinorVersion: true
    protectedSettings:{
      commandToExecute: 'apt-get update && apt-get install nginx -y && sed -i "s/Welcome to nginx/Welcome to nginx from ${vmName}/g" /var/www/html/index.nginx-debian.html'
    }
  }
}

output pipIp string = pip.properties.ipAddress
