# References
# https://docs.microsoft.com/en-us/azure/virtual-desktop/powershell-module

# Set up your PowerShell environment
Install-Module -Name Az.DesktopVirtualization # installs the DesktopVirtualization module

Connect-AzAccount # log in with the admin-biagtan@rbiagtangmail.onmicrosoft.com account
Get-AzLocation #to search for supported locations; make note of the "location" value
$location="westus2"

# Create a Host Pool
$hostPool="HostPool05022020"
$subscription = "bbd912be-643f-4d7c-98f1-93cefa87d702"
$rsg="rsg-wvd052020"
$workspace="Workspace052020"
$appgroupname = "HostPool05022020-DAG"
$remoteapp='Remote App'
New-AzWvdHostPool -ResourceGroupName <resourcegroupname> -Name <hostpoolname> -WorkspaceName <workspacename> -HostPoolType <RemoteApp|Desktop>  -Location -DesktopAppGroupName <appgroupname>
Get-AzWvdHostPool -ResourceGroupName $rsg -Name $hostPool -SubscriptionId $subscription

# Assign users to the default desktop app group
New-AzRoleAssignment -SignInName cyclops@rlb-marvel.com -RoleDefinitionName "Desktop Virtualization User" -ResourceName $appgroupname -ResourceGroupName $rsg -ResourceType 'Microsoft.DesktopVirtualization/applicationGroups' -Verbose
# Assign users to Remote App
New-AzRoleAssignment -SignInName cyclops@rlb-marvel.com -RoleDefinitionName "Desktop Virtualization User" -ResourceName $remoteapp -ResourceGroupName $rsg -ResourceType 'Microsoft.DesktopVirtualization/applicationGroups' -Verbose
# Check what assignments a user has
Get-AzRoleAssignment -SignInName "cyclops@rlb-marvel.com" -RoleDefinitionName "Desktop Virtualization User"