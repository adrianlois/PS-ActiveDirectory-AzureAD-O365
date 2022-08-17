# Get ADUsers Last WhenCreated

Get the AD users created in the last 30 days and sorted by creation date. We can filter by name with findstr for a more specific result.
```powershell
$lastDays = ((Get-Date).AddDays(-30)).Date
Get-ADUser -Filter {whenCreated -ge $lastDays} -Properties whenCreated | Select-Object Name, whenCreated | Sort-Object whenCreated | findstr /i "Alice"
```

Get the all AD users sorted by creation date of a specific OU.
```powershell
Get-ADUser -Filter * -SearchBase "OU=Finance,OU=Departments,DC=domain,DC=local" -Properties whenCreated | Select-Object Name, whenCreated | Sort-Object whenCreated
```