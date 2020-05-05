######################################################
# WVD Phase 2: Create WVD Tenant and Service Principal
# 
# Author: Rod Biagtan
# 
# Reference links:
# https://docs.microsoft.com/en-us/azure/virtual-desktop/tenant-setup-azure-active-directory
# https://securityboulevard.com/2019/11/windows-virtual-desktop-the-best-step-by-step-walkthrough/
# https://www.christiaanbrinkhoff.com/2020/03/22/windows-virtual-desktop-technical-walkthrough-including-other-unknown-secrets-you-did-not-know-about-the-new-microsoft-managed-azure-service/
# http://www.rebeladmin.com/2019/04/step-step-guide-azure-windows-virtual-desktop-preview/
# https://www.jasonsamuel.com/2020/03/02/how-to-use-microsoft-wvd-windows-10-multi-session-fslogix-msix-app-attach-to-build-an-azure-powered-virtual-desktop-experience/
# https://techcommunity.microsoft.com/t5/windows-it-pro-blog/getting-started-with-windows-virtual-desktop/ba-p/391054
# https://www.jasonsamuel.com/2020/03/02/how-to-use-microsoft-wvd-windows-10-multi-session-fslogix-msix-app-attach-to-build-an-azure-powered-virtual-desktop-experience/#WVD_Tenant_and_Host_Pools
#
######################################################


# STEP 1: Define variables
$tenantName="rbiagtangmail.onmicrosoft.com"
$tenantID="b7f577ae-7448-48ba-8419-a3381fdb700c"
$subscriptionID="bbd912be-643f-4d7c-98f1-93cefa87d702"
$hostpoolname="WVD-0420"
$appgroup="Remote Application Group"
$userUPN="admin-rbiagtan@rbiagtangmail.onmicrosoft.com"

# STEP 2: Download & Install WVD Cmdlets 
Set-executionpolicy -executionpolicy unrestricted
Install-Module -Name Microsoft.RDInfra.RDPowerShell -Force
Import-Module -Name Microsoft.RDInfra.RDPowerShell
Update-Module -Name Microsoft.RDInfra.RDPowerShell
Install-Module -Name Az -AllowClobber -Force
Import-Module -Name AzureAD

# STEP 3: Sign in to WVD Environment
Add-RdsAccount -DeploymentUrl "https://rdbroker.wvd.microsoft.com"

# STEP 4: Assign Additional Users to the Desktop Application Group
Add-RdsAppGroupUser $tenantName $hostpoolname "Desktop Application Group" -UserPrincipalName $userUPN

# STEP 5a: Create a RemoteApp Group
New-RdsAppGroup $tenantName $hostpoolname $appgroup -ResourceType "RemoteApp"
# STEP 5b: Verify that the RemoteApp Group was created
get-rdsappgroup $tenantName $hostpoolname
# STEP 5c: Get a list of Start menu apps. Make note of the FilePath, IconPath, IconIndex 
Get-RdsStartMenuApp $tenantName $hostpoolname $appgroup
# STEP 5d: Publish an app (e.g. Wordpad) using the AppAlias value from 5c
New-RdsRemoteApp $tenantName $hostpoolname $appgroup -Name "Wordpad" -AppAlias Wordpad
# STEP 5e: View & verify list of published apps
Get-RdsRemoteApp $tenantName $hostpoolname $appgroup
# STEP 5f: Grant users access to the RemoteApp programs in the app group
Add-RdsAppGroupUser $tenantName $hostpoolname $appgroup -UserPrincipalName $userUPN

# Client Access Methods
# Windows Client: 
#    1) Download at http://aka.ms/wvd/clients/windows
#    2) Subscribe to https://rdweb.wvd.microsoft.com
#
# Web Portal: https://rdweb.wvd.microsoft.com/webclient/index.html
#
# Mac Client
#   1) Download Remote Desktop Client from App Store
#   2) Create a Workspace and point to https://rdweb.wvd.microsoft.com