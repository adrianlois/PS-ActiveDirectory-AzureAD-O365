# Load Active Directory module
Import-Module ActiveDirectory

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
    $Name = $_."Name"
    $Path = $_."Path"
    $Description = $_."Description"

# Description Computer Object AD
    Get-ADComputer -Identity "$Name" | Move-ADObject -TargetPath "$Path"

# Move Computer Object AD
    Get-ADComputer -Identity "$Name" | Set-ADObject -Description "$Description"
}
