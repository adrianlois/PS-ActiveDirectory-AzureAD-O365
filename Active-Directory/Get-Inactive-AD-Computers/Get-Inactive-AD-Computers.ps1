Import-Module ActiveDirectory

$Domain = "domain.local"
$DaysInactive = 90
$CreatePathFile = "C:\Users\adrian\Desktop\InactiveADComputers.csv"
$Time = (Get-Date).Adddays(-($DaysInactive))

Get-ADComputer -Filter {LastLogonTimeStamp -lt $Time} -Properties LastLogonTimeStamp | `
Select-Object Name,@{Name="Stamp";Expression={[DateTime]::FromFileTime($_.lastLogonTimestamp)}} | `
Export-Csv $CreatePathFile
