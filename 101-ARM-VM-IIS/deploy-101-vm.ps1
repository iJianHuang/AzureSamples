<#
 .SYNOPSIS
    Deploys a template to Azure

 .DESCRIPTION
    Deploys an Azure Resource Manager template

 .PARAMETER subscriptionId
    The subscription id where the template will be deployed.

 .PARAMETER environmentName
    The environment name is the environment will be created. Keep it short. Use only lower case a-z and 0-9.
    It will be used to construct resourceGroupName.
    The resource group where the template will be deployed. Can be the name of an existing or a new resource group.

 .PARAMETER resourceGroupLocation
    Optional, a resource group location. If specified, will try to create a new resource group in this location. If not specified, assumes resource group is existing.

 .PARAMETER deploymentName
    The deployment name.
    
 .PARAMETER adminPassword
    VM admin password. Use lower/upper cases, numbers, and special chars. Example: $2k9H234@wN4l6y# 

 .PARAMETER templateFilePath
    Optional, path to the template file. Defaults to template.json.

 .PARAMETER parametersFilePath
    Optional, path to the parameters file. Defaults to parameters.json. If file is not found, will prompt for parameter values based on template.
#>

param(
 [Parameter(Mandatory=$True)]
 [string]
 $subscriptionId,

 [Parameter(Mandatory=$True)]
 [string]
 $environmentName,

 [string]
 $resourceGroupLocation,

 [Parameter(Mandatory=$True)]
 [string]
 $deploymentName,

 [Parameter(Mandatory=$True)]
 [string]
 $adminPassword,
 
 [string]
 $templateFilePath = "template-101-vm.json",

 [string]
 $parametersFilePath = "parameters-101-vm.json"
)

<#
.SYNOPSIS
    Registers RPs
#>
Function RegisterRP {
    Param(
        [string]$ResourceProviderNamespace
    )

    Write-Host "Registering resource provider '$ResourceProviderNamespace'";
    Register-AzResourceProvider -ProviderNamespace $ResourceProviderNamespace;    
}

#******************************************************************************
# Script body
# Execution begins here
#******************************************************************************
$ErrorActionPreference = "Stop"

# deployment variables
$resourceGroupName = "$environmentName-rg"

# sign in
Write-Host "Logging in...";
Connect-AzAccount;

# select subscription
Write-Host "Selecting subscription '$subscriptionId'";
Select-AzSubscription -SubscriptionID $subscriptionId;

# Register RPs
$resourceProviders = @("microsoft.network","microsoft.compute","microsoft.devtestlab");
if($resourceProviders.length) {
    Write-Host "Registering resource providers"
    foreach($resourceProvider in $resourceProviders) {
        RegisterRP($resourceProvider);
    }
}

#Create or check for existing resource group
$resourceGroup = Get-AzResourceGroup -Name $resourceGroupName -ErrorAction SilentlyContinue
if(!$resourceGroup)
{
    Write-Host "Resource group '$resourceGroupName' does not exist. To create a new resource group, please enter a location.";
    if(!$resourceGroupLocation) {
        $resourceGroupLocation = Read-Host "resourceGroupLocation";
    }
    Write-Host "Creating resource group '$resourceGroupName' in location '$resourceGroupLocation'";
    New-AzResourceGroup -Name $resourceGroupName -Location $resourceGroupLocation
}
else{
    Write-Host "Using existing resource group '$resourceGroupName'";
}

# Secure password
$adminPasswordSecure = $adminPassword | ConvertTo-SecureString -AsPlainText -Force

# Start the deployment
Write-Host "Starting deployment...";
if(Test-Path $parametersFilePath) {
    New-AzResourceGroupDeployment `
        -ResourceGroupName $resourceGroupName `
        -Name $deploymentName `
        -adminPassword $adminPasswordSecure `
        -TemplateFile $templateFilePath `
        -environmentName $environmentName `
        -TemplateParameterFile $parametersFilePath;
} else {
    New-AzResourceGroupDeployment `
        -ResourceGroupName $resourceGroupName `
        -Name $deploymentName `
        -adminPassword $adminPasswordSecure `
        -environmentName $environmentName `
        -TemplateFile $templateFilePath;
}

Write-Host "IP: "
Get-AzPublicIPAddress -ResourceGroupName $resourceGroup | select IpAddress

# RDP
# mstsc.exe /v <PUBLIC_IP_ADDRESS>

# clean up
# $job = Remove-AzResourceGroup -Name $resourceGroup -Force -AsJob
# $job
