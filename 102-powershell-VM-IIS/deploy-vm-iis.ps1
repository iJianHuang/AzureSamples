$ErrorActionPreference = "Stop"

# Variables for common values
$myTag = "configVMIIS"
$resourceGroup = "$myTag-rg"
$location = "eastus"
$vmName = "$myTag-vm"

Connect-AzAccount;

# Create user object
$cred = Get-Credential -Message "Enter a username and password for the virtual machine."

# Create a resource group
New-AzResourceGroup -Name $resourceGroup -Location $location

# Create a subnet configuration
$subnetConfig = New-AzVirtualNetworkSubnetConfig -Name "$myTag-subnet" -AddressPrefix 192.168.1.0/24

# Create a virtual network
$vnet = New-AzVirtualNetwork -ResourceGroupName $resourceGroup -Location $location `
  -Name "$myTag-vnet" -AddressPrefix 192.168.0.0/16 -Subnet $subnetConfig

# Create a public IP address and specify a DNS name. "$myTag-pip-$(Get-Random)"
$pip = New-AzPublicIpAddress -ResourceGroupName $resourceGroup -Location $location `
  -Name "$myTag-pip" -AllocationMethod Static -IdleTimeoutInMinutes 4

# Create an inbound network security group rule for port 3389
$nsgRuleRDP = New-AzNetworkSecurityRuleConfig -Name "$myTag-nsg-RDP"  -Protocol Tcp `
  -Direction Inbound -Priority 1000 -SourceAddressPrefix * -SourcePortRange * -DestinationAddressPrefix * `
  -DestinationPortRange 3389 -Access Allow

# Create an inbound network security group rule for port 80
$nsgRuleHttp = New-AzNetworkSecurityRuleConfig -Name "$myTag-nsg-http" -Description "Allow HTTP" 
    -Access Allow -Protocol Tcp -Direction Inbound -Priority 1001 -SourceAddressPrefix 
    Internet -SourcePortRange * -DestinationAddressPrefix * -DestinationPortRange 80

# Create a network security group
$nsg = New-AzNetworkSecurityGroup -ResourceGroupName $resourceGroup -Location $location `
  -Name "$myTag-nsg" -SecurityRules $nsgRuleRDP,$nsgRuleHttp

# Create a virtual network card and associate with public IP address and NSG
$nic = New-AzNetworkInterface -Name "$myTag-nic" -ResourceGroupName $resourceGroup -Location $location `
  -SubnetId $vnet.Subnets[0].Id -PublicIpAddressId $pip.Id -NetworkSecurityGroupId $nsg.Id

# Create a virtual machine configuration
$vmConfig = New-AzVMConfig -VMName $vmName -VMSize Standard_D1 | `
Set-AzVMOperatingSystem -Windows -ComputerName $vmName -Credential $cred | `
Set-AzVMSourceImage -PublisherName MicrosoftWindowsServer -Offer WindowsServer -Skus 2016-Datacenter -Version latest | `
Add-AzVMNetworkInterface -Id $nic.Id

# Create a virtual machine
New-AzVM -ResourceGroupName $resourceGroup -Location $location -VM $vmConfig

# Install IIS
Set-AzVMExtension -ResourceGroupName $resourceGroup `
    -ExtensionName "IIS" `
    -VMName $vmName `
    -Location $location `
    -Publisher Microsoft.Compute `
    -ExtensionType CustomScriptExtension `
    -TypeHandlerVersion 1.8 `
    -SettingString '{"commandToExecute":"powershell Add-WindowsFeature Web-Server; powershell Add-Content -Path \"C:\\inetpub\\wwwroot\\Default.htm\" -Value $($env:computername)"}'

Write-Host "IP: "
Get-AzPublicIPAddress -ResourceGroupName $resourceGroup | select IpAddress

    
# RDP
# mstsc.exe /v <PUBLIC_IP_ADDRESS>


# clean up
# $job = Remove-AzResourceGroup -Name $resourceGroup -Force -AsJob
# $job