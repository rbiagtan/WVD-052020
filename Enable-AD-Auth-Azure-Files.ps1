######################################################
# Enable Azure AD Authentication for Azure Files
# 
# Author: Rod Biagtan
# 
# Date: Apr. 29, 2020
# Reference links:
# http://www.rebeladmin.com/2019/08/step-step-guide-enable-azure-ad-authentication-azure-files/
# 
######################################################

Import-Module -Name Az
Connect-AzAccount
Connect-AzureAD

get-azurermlocation | ft
New-AzStorageAccount -ResourceGroupName "AzureFileRG" -Name "azfilesa1" -Location "westus2" -SkuName Standard_LRS -Kind StorageV2 -EnableAzureActiveDirectoryDomainServicesForFile $true