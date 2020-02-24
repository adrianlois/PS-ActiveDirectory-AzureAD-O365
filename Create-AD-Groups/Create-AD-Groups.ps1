Import-Module ActiveDirectory

$ImportFileCSV = "import-file.csv"

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