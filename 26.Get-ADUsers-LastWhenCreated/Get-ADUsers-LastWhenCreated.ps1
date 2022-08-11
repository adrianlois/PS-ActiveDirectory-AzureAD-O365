$lastDays = ((Get-Date).AddDays(-30)).Date
Get-ADUser -Filter {whenCreated -ge $lastDays} -Properties whenCreated | Select-Object Name, whenCreated | Sort-Object whenCreated | findstr /i "UserName"