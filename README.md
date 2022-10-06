# Introduction 
This is an example of how to create a VM with a Custom Script Extension to install Nginx in Azure using Bicep.

![Architecture Diagram](https://github.com/ssemyan/BicepVmWithCustomScript/raw/main/VMArchitecture.png)

# Getting Started
To deploy, you need the Azure CLI installed and logged in. You also need the Bicep extensions. 

Versions used for this project:
Az CLI:   2.37.0
Az Bicep: 0.7.4

# Settings
The *executeDeploy.sh* bash script has the following variables:

*  DEPLOY_ENV - the environment name used in all resource names
*  DEPLOY_LOC - Azure region (e.g. westeurope, westus3, etc.)
*  RG_NAME - Resource group name (will be created if not already existing). Defaults to "rg-vmtest-$DEPLOY_ENV-$DEPLOY_LOC"
*  ADMIN_USER - Admin username for the VM. Defaults to current user.
*  ADMIN_SSH_KEY - Admin SSH key. Defaults to the public key in *~/.ssh/id_rsa.pub*
*  IP_WHITELIST_RANGE - IP address range to whitelist to access SSH port 22 on the VM. Defaults to the current external IP when run. 

# Naming Conventions
Resource names are created based on the environment and location and follow the CAF [suggested naming best practice](https://docs.microsoft.com/en-us/azure/cloud-adoption-framework/ready/azure-best-practices/resource-naming) and with consideration of the [naming rules and restrictions for Azure resources](https://docs.microsoft.com/en-us/azure/azure-resource-manager/management/resource-name-rules).

## Template
`[resource-type]-[environment]-[region]-[instance|unique id]`

## Naming Examples
#### VNET
vnet-dev-westus3

#### Public IP Address
vm-dev-westus3-001

# Custom Script Extension
The [Custom Script Extension](https://learn.microsoft.com/en-us/azure/virtual-machines/extensions/custom-script-linux) allows for running commands or full scripts on the VM on first boot. You can in-line scripts or download them from Azure Storage. For this example, I simply in-lined the following:

```
apt-get update && apt-get install nginx -y && sed -i "s/Welcome to nginx/Welcome to nginx from ${vmName}/g" /var/www/html/index.nginx-debian.html
```

This will install nginx and then update the index page to include the name of the VM. 

# Running the sample
Ensure you are logged into the proper subscription (e.g. `az login`) and then you can then run the *BASH* script:
`./executeDeploy.sh`

This script first does a test run and shows what will be changed. To proceed, type 'y'. Any other character will stop the script. 

# Output
Once everything is deployed the script will output the public IP address of the VM. You can then use this IP address in a web browser to see the nginx welcome page with the VM name. 

# Logging
All logs are sent to a single Log Analytics workspace (30 day retention) and storage account (180 day retention) in the monitoring resource group. 
