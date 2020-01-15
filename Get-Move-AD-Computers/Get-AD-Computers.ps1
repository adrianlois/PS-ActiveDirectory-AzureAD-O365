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

# Get AD Computers. Criteria matching an AD computer object name
# findstr /b: Matches the text pattern if it is at the beginning of a line
    Get-ADComputer -LDAPFilter "(name=*$Name*)" | findstr /b "Name"
}
