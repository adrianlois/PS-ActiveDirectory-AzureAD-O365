# Load Active Directory module
Import-Module ActiveDirectory

# Load file CSV (Comma separated values and UTF-8 encoding)
$ImportFileCSV = "import-file.csv"

# Import file and start loop
Import-Csv $ImportFileCSV | Foreach-Object {

$Group = $_."Group"
$Path = $_."Path"
$Description = $_."Description"

    New-ADGroup `
        -Name "$Group" `
        -SamAccountName "$Group" `
        -GroupCategory Security `
        -GroupScope Global `
        -DisplayName "$Group" `
        -Path "$Path" `
        -Description "$Description"
}