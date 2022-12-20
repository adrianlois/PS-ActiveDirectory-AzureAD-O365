# https://learn.microsoft.com/en-us/powershell/module/activedirectory/get-adcomputer?view=windowsserver2022-ps
# Get-Module ActiveDirectory
# Import-Module ActiveDirectory

$FileImportCSV = "C:\Scripts\CSV\DNSHostName.csv"

Import-Csv $FileImportCSV | Foreach-Object {

    $DNSHostName = $_."DNSHostName"

    Get-ADComputer -Identity "$DNSHostName" -Properties * | `
    Select-Object DistinguishedName,DNSHostName,IPv4Address,LastLogonDate,whenCreated,OperatingSystem,OperatingSystemVersion
}