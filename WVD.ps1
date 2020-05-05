######################################################
# PowerShell commands to create a WVD Tenant
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

# STEP 2: Download & Install WVD Cmdlets 
Set-executionpolicy -executionpolicy unrestricted
Install-Module -Name Microsoft.RDInfra.RDPowerShell -Force
Import-Module -Name Microsoft.RDInfra.RDPowerShell
Update-Module -Name Microsoft.RDInfra.RDPowerShell
Install-Module -Name Az -AllowClobber -Force
Import-Module -Name AzureAD

# STEP 3: Add RDS AzAccount
Add-RdsAccount -DeploymentUrl "https://rdbroker.wvd.microsoft.com"

# STEP 4: Create WVD Tenant
New-RdsTenant -Name $tenantName -AadTenantId $tenantID -AzureSubscriptionId $subscriptionID

# STEP 5: Create RDS Owner
New-RdsRoleAssignment -TenantName $tenantName -SignInName admin-rbiagtan@rbiagtangmail.onmicrosoft.com -RoleDefinitionName "RDS Owner"

# STEP 6a: Create a Service Principal in Azure AD
$aadContext = Connect-AzureAD
$svcPrincipal = New-AzureADApplication -AvailableToOtherTenants $true -DisplayName "Windows Virtual Desktop Svc Principal"
$svcPrincipalCreds = New-AzureADApplicationPasswordCredential -ObjectId $svcPrincipal.ObjectId
# STEP 6b: Gather Service Principal Credentials
# Run the next 3 cmdlets and make note of the values because they'll be needed later
$svcPrincipalCreds.Value  ### Service Principal Password         ###
$aadContext.TenantId.Guid ### Service Principal's Tenant ID      ###
$svcPrincipal.AppId       ### Service Principal's Application ID ###
# STEP 6c: Grant Service Principal the RDW Owner Role
New-RdsRoleAssignment -RoleDefinitionName "RDS Owner" -ApplicationId $svcPrincipal.AppId -TenantName $tenantName
# STEP 6d: Verify You Can Sign in with the Service Principal Account
$creds = New-Object System.Management.Automation.PSCredential($svcPrincipal.AppId, (ConvertTo-SecureString $svcPrincipalCreds.Value -AsPlainText -Force))
Add-RdsAccount -DeploymentUrl "https://rdbroker.wvd.microsoft.com" -Credential $creds -ServicePrincipal -AadTenantId $aadContext.TenantId.Guid
Get-RdsTenant

# 6: Create a RDS Host Pool
# WVD-Host-Pool01 will contain full desktops
# WVD-Host-Pool02 will contain published apps
New-RdsHostPool -TenantName rbiagtangmail.onmicrosoft.com -Name "WVD-Host-Pool01"
New-RdsHostPool -TenantName rbiagtangmail.onmicrosoft.com -Name "WVD-Host-Pool02"
# Remove RDS Hostpool
Remove-RdsHostPool -TenantName rbiagtangmail.onmicrosoft.com -Name "WVD-Host-Pool01"

# 7: Create Desktop and Remote Application Groups
# Command isn't working: New-RdsAppGroup -TenantName rbiagtangmail.onmicrosoft.com -HostPoolName WVD-Host-Pool01 -AppGroupName “Desktop Application Group”
# Command isn't working: New-RdsAppGroup -TenantName rbiagtangmail.onmicrosoft.com -HostPoolName WVD-Host-Pool02 -AppGroupName “Remote Application Group”

# 8: Assign WVD Desktop Application Group
Add-RdsAppGroupUser -TenantName  rbiagtangmail.onmicrosoft.com -HostPoolName WVD-Host-Pool01 -AppGroupName “Desktop Application Group” -UserPrincipalName admin-rbiagtan@rbiagtangmail.onmicrosoft.com
# Go to https://rdweb.wvd.microsoft.com/webclient/index.html to test the user


# Create a service principal in Azure AD
Import-Module AzureAD
$aadContext = Connect-AzureAD
$svcPrincipal = New-AzureADApplication -AvailableToOtherTenants $true -DisplayName "Windows Virtual Desktop Svc Principal"
$svcPrincipalCreds = New-AzureADApplicationPasswordCredential -ObjectId $svcPrincipal.ObjectId

# Assign additional users to the desktop application group
Add-RdsAccount -DeploymentUrl "https://rdbroker.wvd.microsoft.com"
Add-RdsAppGroupUser rbiagtangmail.onmicrosoft.com Hostpool1425 "Desktop Application Group" -UserPrincipalName admin-jbiagtan@rbiagtangmail.onmicrosoft.com

# Variables used for creating a RemoteApp group
$tenant="rbiagtangmail.onmicrosoft.com"
$hostpoolname="Hostpool1425"
$appGroupName="Desktop Application Group"
$rdsremoteappgroupname="Remote App Group"

# Create a RemoteApp group
New-RdsAppGroup $tenant $hostpoolname $appGroupName -ResourceType "RemoteApp"

New-RdsAppGroup -TenantName $tenant -HostPoolName $hostpoolname -Name "Remote App Group" -ResourceType RemoteApp

Get-RdsStartMenuApp -TenantName $tenant -HostPoolName $hostpoolname -AppGroupName $rdsremoteappgroupname
New-RdsRemoteApp -TenantName $tenant -HostPoolName $hostpoolname -AppGroupName $rdsremoteappgroupname -Name "Wordpad" -AppAlias "Wordpad"

# Add users to app group
Add-RdsAppGroupUser -TenantName $tenant -HostPoolName $hostpoolname -AppGroupName $rdsremoteappgroupname -UserPrincipalName admin-rbiagtan@rbiagtangmail.onmicrosoft.com

# Check to make sure the app is published
Get-RdsRemoteApp $tenant $hostpoolname $rdsremoteappgroupname

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