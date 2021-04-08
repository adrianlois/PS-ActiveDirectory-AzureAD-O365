# Load Active Directory module
Import-Module ActiveDirectory

# Load file CSV (Comma separated values and UTF-8 encoding)
$ImportFileCSV = "import-file.csv"

# Import file and start loop
Import-Csv $ImportFileCSV | Foreach-Object {

# Set variables
$Group = $_."Group"
$Path = $_."Path"
$Description = $_."Description"

   # Check if group already exists
   $SamAccountExist = Get-ADGroup -Filter 'SamAccountName -Like $SamAccountName'

      If ( -not $SamAccountExist ) {
         New-ADGroup `
            -Name "$Group" `
            -SamAccountName "$Group" `
            -GroupCategory Security `
            -GroupScope Global `
            -DisplayName "$Group" `
            -Path "$Path" `
            -Description "$Description"
      } Else {
         Write-Host "`n[+] The group already exists in AD: $Group"
      }
}