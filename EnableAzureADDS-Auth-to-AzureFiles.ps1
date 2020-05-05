$tenantID="b7f577ae-7448-48ba-8419-a3381fdb700c"
$resourceGroupName = "rsg1"
$storageAccountName = "rlbprofilestorage"
$subscriptionID="bbd912be-643f-4d7c-98f1-93cefa87d702"
$subscriptionName="Visual Studio Enterprise Subscription – MPN"

# Step 1: Enable Azure AD DS authentication for Storage Account
Set-AzStorageAccount -ResourceGroupName $resourceGroupName `
    -Name $storageAccountName `
    -EnableAzureActiveDirectoryDomainServicesForFile $true

# Step 2: Assign access permissions to an identity