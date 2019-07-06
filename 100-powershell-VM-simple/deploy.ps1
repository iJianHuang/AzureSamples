$ErrorActionPreference = "Stop"

Connect-AzAccount;
New-AzResourceGroup -Name VerySimpleVM-rg -Location eastus

$cred = Get-Credential -Message "Enter a username and password for the virtual machine."

$vmParams = @{
  ResourceGroupName = 'VerySimpleVM-rg'
  Name = 'VerySimpleVM1'
  Location = 'eastus'
  ImageName = 'Win2016Datacenter'
  PublicIpAddressName = 'VerySimplePublicIp'
  Credential = $cred
  OpenPorts = 3389
}
$newVM1 = New-AzVM @vmParams

$newVM1

$newVM1.OSProfile | Select-Object ComputerName,AdminUserName

$newVM1 | Get-AzNetworkInterface |
  Select-Object -ExpandProperty IpConfigurations |
    Select-Object Name,PrivateIpAddress
    
$publicIp = Get-AzPublicIpAddress -Name VerySimplePublicIp -ResourceGroupName VerySimpleVM-rg

$publicIp | Select-Object Name,IpAddress,@{label='FQDN';expression={$_.DnsSettings.Fqdn}}

# RDP
# mstsc.exe /v <PUBLIC_IP_ADDRESS>

#$vm2Params = @{
#  ResourceGroupName = 'VerySimpleVM-rg'
#  Name = 'VerySimpleVM2'
#  ImageName = 'Win2016Datacenter'
#  VirtualNetworkName = 'VerySimpleVM1'
#  SubnetName = 'VerySimpleVM1'
#  PublicIpAddressName = 'VerySimplePublicIp2'
#  Credential = $cred
#  OpenPorts = 3389
#}
#$newVM2 = New-AzVM @vm2Params
#$newVM2

# clean up
# $job = Remove-AzResourceGroup -Name VerySimpleVM-rg -Force -AsJob
# $job