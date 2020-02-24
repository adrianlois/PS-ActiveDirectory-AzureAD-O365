# Load Active Directory module
Import-Module ActiveDirectory
Import-Module AzureAD
Import-Module MSOnline

# Connect AzureAD and Office365
Connect-AzureAD
Connect-MsolService

# LoadBox File Prompt: Select CSV file
# Comma separated values and UTF-8 encoding
New-Object System.Windows.Forms.OpenFileDialog -Property @{ InitialDirectory = [Environment]::GetFolderPath('Desktop') }
$FileBrowser = New-Object System.Windows.Forms.OpenFileDialog -Property @{ 
    InitialDirectory = [Environment]::GetFolderPath('Desktop') 
    Filter = 'Documents (*.csv)|*.csv'
}
$FileImportCSV = $FileBrowser.ShowDialog()

# Import file and start loop
Import-Csv $FileImportCSV | foreach-object {

# Set variables
    $EmailAddress = $_."EmailAddress"

# List the license plans O365
    Get-AzureADSubscribedSku | Select SkuPartNumber

# Get the license plan ID associated with an O365 User account
    Get-AzureADUser -ObjectID "$EmailAddress" | Select -ExpandProperty AssignedLicenses | Select SkuID
}
