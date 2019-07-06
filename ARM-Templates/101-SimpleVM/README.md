101 - A simple vm with IIS. This VM is configured with security in mind. Only three ports (http 80, https 443, RDP 3389). 

The environment name is very important because it is used for creating the whole devtest lab environment, and later for cleaning up resources. In addition, it is used to prefix all the resources including the VM. There are different naming conventions for resources so please use lower case and number only for this environment name. Some examples are dev, dev123, qa, etc.

You can deploy this VM by two methods.
1. Click on 'Deploy to Azure' button, or
2. Run the deploy-101-vm.ps1 with powershell

After deployment, you can verify by browsing to http://machine-ipaddress

<a href="https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FiJianHuang%2FAzureSamples%2Fmaster%2FARM-Templates%2F101-SimpleVM%2Ftemplate-101-vm.json%0D%0A" target="_blank">
    <img src="http://azuredeploy.net/deploybutton.png"/>
</a>

<a href="http://armviz.io/#/?load=https%3A%2F%2Fraw.githubusercontent.com%2FiJianHuang%2FAzureSamples%2Fmaster%2FARM-Templates%2F101-SimpleVM%2Ftemplate-101-vm.json%0D%0A" target="_blank">
    <img src="http://armviz.io/visualizebutton.png"/>
</a>

