$Days = 90
$Time = (Get-Date).Adddays(-($Days))
$ExportFilePath = "%USERPROFILE%\Desktop\ADUsersLastLogon.csv"

Get-ADUser -Filter {LastLogonTimeStamp -lt $Time} -Properties * | `
Where-Object {$_.Enabled -like "True"} | `
Select-Object Name,EmailAddress,DistinguishedName,SamAccountName,PasswordNeverExpires,Enabled,whenCreated,LastLogonDate | `
Export-Csv -Path $ExportFilePath -Delimiter ';' -NoTypeInformation