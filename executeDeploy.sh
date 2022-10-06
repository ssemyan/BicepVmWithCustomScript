#!/bin/bash

# Stop on errors, unset variables, and pass back the error code
set -eu pipefail

# Script to deploy bicep resources to Azure
# Assumes runner is already logged into Azure and has contribute role

# Set the environment (dev, test, prod) and region (used to name resources)
DEPLOY_ENV='dev'
DEPLOY_LOC='westus3'

# Resource group name (Bicep will create the group if not already existing)
RG_NAME="rg-vmtest-$DEPLOY_ENV-$DEPLOY_LOC"

# Set the admin username and ssh key to currently logged in user
ADMIN_USER=$USER
ADMIN_SSH_KEY="$(cat ~/.ssh/id_rsa.pub)"

# Set the IP address range to whitelist 
# Default to current external IP
IP_WHITELIST_RANGE=$(dig +short myip.opendns.com @resolver1.opendns.com)/32

# Create unique name for deployment
deploymentName='WD_Deployment_'$DEPLOY_ENV'_'$DEPLOY_LOC'_'$(date +"%Y%m%d%H%M%S")
echo "New deployment: $deploymentName"

# Show active subscription
echo ''
echo 'Active Subscription: '
echo ''
az account show -o table

# Deploy
echo ''
echo "Testing Deployment"
echo ''

DEPLOY_CMD="az deployment sub create --name $deploymentName --location $DEPLOY_LOC --template-file main.bicep --parameters environ=$DEPLOY_ENV location=$DEPLOY_LOC \
  adminUsername=$ADMIN_USER adminSshKey=\"$ADMIN_SSH_KEY\" sshIpAddressRange=\"$IP_WHITELIST_RANGE\" resourceGroupName=$RG_NAME"

echo $DEPLOY_CMD

eval "$DEPLOY_CMD -w"

# Ask for conf
read -p "Continue with deploy (y/n)?" CONT
if [ "$CONT" != "y" ]; then
  exit 0
fi

echo ''
echo 'Deploying...'
echo ''

eval "$DEPLOY_CMD"

echo ''
echo "Deployment complete into resource group $RG_NAME"
echo 'Public IP address of VM:'
az deployment sub show -n $deploymentName --query properties.outputs.vmPipIp.value