$ErrorActionPreference = "Stop"
# Variables for common values
$resourceGroup = "VerySimpleVM-rg2"
$location = "eastus"
$vmName = "VerySimpleVM"

Connect-AzAccount;

# Create user object
$cred = Get-Credential -Message "Enter a username and password for the virtual machine."

# Create a resource group
New-AzResourceGroup -Name $resourceGroup -Location $location

# Create a virtual machine
New-AzVM `
  -ResourceGroupName $resourceGroup `
  -Name $vmName `
  -Location $location `
  -ImageName "Win2016Datacenter" `
  -VirtualNetworkName "VerySimpleVM-vnet" `
  -SubnetName "VerySimpleVM-subnet" `
  -SecurityGroupName "VerySimpleVM-nsg" `
  -PublicIpAddressName "VerySimpleVM-pip" `
  -Credential $cred `
  -OpenPorts 3389

# RDP
# mstsc.exe /v <PUBLIC_IP_ADDRESS>



# clean up
# $job = Remove-AzResourceGroup -Name VerySimpleVM-rg2 -Force -AsJob
# $job