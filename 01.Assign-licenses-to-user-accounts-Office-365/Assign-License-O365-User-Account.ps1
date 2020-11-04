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
    $UsageLocation = $_."UsageLocation"
    $License = $_."License"

# Set country and assign licenses Office365 to AD users
    Set-MsolUser -UserPrincipalName "$EmailAddress" -UsageLocation $UsageLocation
    Set-MsolUserLicense -UserPrincipalName "$EmailAddress" -AddLicenses "DOMAIN:$License"
}
