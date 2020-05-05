$tenantID="b7f577ae-7448-48ba-8419-a3381fdb700c"
$resourceGroupName = "rsg1"
$storageAccountName = "rlbprofilestorage"
$subscriptionID="bbd912be-643f-4d7c-98f1-93cefa87d702"
$subscriptionName="Visual Studio Enterprise Subscription – MPN"

# Install PowerShell Modules
Install-Module -Name Az -AllowClobber -Scope AllUsers

# Connect to Azure with a browser sign in token
Connect-AzAccount #log in with admin-rbiagtan@rbiagtangmail.onmicrosoft.com

# Show Selected Azure Subscription
Get-AzContext -ListAvailable
Get-AzSubscription -SubscriptionName 'MySubscriptionName' | Set-AzContext -Name 'MyContextName'

# Change Tenant and Subscription
Set-AzContext -Subscription $subscriptionID

# Check subscriptions
Get-AzSubscription

# This command requires you to be logged into your Azure account, run Login-AzAccount if you haven't
# already logged in.
$storageAccount = Get-AzStorageAccount -ResourceGroupName $resourceGroupName -Name $storageAccountName

# The ComputerName, or host, is <storage-account>.file.core.windows.net for Azure Public Regions.
# $storageAccount.Context.FileEndpoint is used because non-Public Azure regions, such as sovereign clouds
# or Azure Stack deployments, will have different hosts for Azure file shares (and other storage resources).
Test-NetConnection -ComputerName ([System.Uri]::new($storageAccount.Context.FileEndPoint).Host) -Port 445