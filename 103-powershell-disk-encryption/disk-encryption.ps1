<#
 .SYNOPSIS
    Encrypt an existing VM disk

 .DESCRIPTION
    Create a key vault and a key manually. The key is used to encrypt an existing VM (DS1-v2) disk.  
    1. enable key's disk encryption feature in Access policies' advanced property.
    2. VM's identity. Turn system identity on.
    3. Might need to start a new PS sessoin to clean the behind-the-scene cache.
#>

param(
 [Parameter(Mandatory=$True)]
 [string]
 $myResourceGroup,

 [Parameter(Mandatory=$True)]
 [string]
 $keyVaultName,

 [Parameter(Mandatory=$True)]
 [string]
 $keyName,

 [Parameter(Mandatory=$True)]
 [string]
 $vmName 
)

#******************************************************************************
# Script body
# Execution begins here
#******************************************************************************
$ErrorActionPreference = "Stop"


Connect-AzAccount;

# $myResourceGroup = "?"
# $keyVaultName = "?"
# $keyName = "?"
# $vmName = "?"


$keyVault = Get-AzKeyVault -VaultName $keyVaultName -ResourceGroupName $myResourceGroup
$diskEncryptionKeyVaultUrl = $keyVault.VaultUri
$keyVaultResourceId = $keyVault.ResourceId
$keyEncryptionKeyUrl = (Get-AzKeyVaultKey -VaultName $keyVaultName -Name $keyName).Key.kid


Set-AzVMDiskEncryptionExtension `
    -ResourceGroupName $myResourceGroup `
    -VMName $vmName `
    -DiskEncryptionKeyVaultUrl $diskEncryptionKeyVaultUrl `
    -DiskEncryptionKeyVaultId $keyVaultResourceId `
    -KeyEncryptionKeyUrl $keyEncryptionKeyUrl `
    -KeyEncryptionKeyVaultId $keyVaultResourceId
    