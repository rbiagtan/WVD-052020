# Created by Rod Biagtan
# Version 1.0 (Apr. 28, 2020)
# Reference: http://azurecentric.com/2019/05/how-to-remove-a-hostpool-from-the-windows-virtual-desktop-on-azure-2/

# Variables
$tenant = "rbiagtangmail.onmicrosoft.com"
$Hostpool = "WVD-0420" # note: to get RDS Host Pool Name use: Get-RdsHostPool -tenant $tenant 

# STEP ZERO - Download & Install WVD Cmdlets
Install-Module -Name Microsoft.RDInfra.RDPowerShell -Force
Import-Module -Name Microsoft.RDInfra.RDPowerShell
Update-Module -Name Microsoft.RDInfra.RDPowerShell
Install-Module -Name Az -AllowClobber -Force
Import-Module -Name AzureAD
# this is a test
# STEP ONE - Login on WVD Desktop Tenant
Add-RdsAccount -DeploymentUrl "https://rdbroker.wvd.microsoft.com"

# STEP TWO - Validate the WVD Infrastructure
Get-RdsTenant
Get-RdsHostPool -TenantName $tenant
Get-RdsSessionHost -TenantName $tenant -HostPoolName $Hostpool
Get-RdsAppGroup -TenantName $tenant -HostPoolName $Hostpool
#Get-RdsAppGroup -TenantName $tenant -HostPoolName $hostpoolname

# STEP THREE - If applicable, must unpublish any published apps
Get-RdsAppGroup -TenantName $tenant -HostPoolName $hostpool #this lists any published apps
Get-RdsRemoteApp -TenantName $tenant -HostPoolName $Hostpool -AppGroupName "Remote Application Group" | Remove-RdsRemoteApp #this removes any published apps
Get-RdsAppGroup -TenantName $tenant -HostPoolName $hostpool -Name "Remote Appplication Group"#this double-checks to make sure all published apps are gone

# STEP FOUR - Remove the Application Group(s)
Get-RdsAppGroup -TenantName $tenant -HostPoolName $Hostpool | Remove-RdsAppGroup
Get-RdsAppGroup -TenantName $tenant -HostPoolName $Hostpool

# STEP FIVE - Remove the Session Host Server(s)
Get-RdsSessionHost -TenantName $tenant -HostPoolName $Hostpool |Remove-RdsSessionHost
Get-RdsSessionHost -TenantName $tenant -HostPoolName $Hostpool

# STEP SIX - Remove the Host Pool
Get-RdsHostPool -TenantName $tenant | Remove-RdsHostPool
Get-RdsHostPool -TenantName $tenant

# STEP SEVEN - Remove the RDS Tenant
Get-RdsTenant | Remove-RdsTenant
Get-RdsTenant