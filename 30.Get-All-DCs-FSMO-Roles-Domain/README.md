# Get all DCs and FSMO roles the domain

Get FSMO roles from the Active Directory domain (Flexible Single Master Operation).
- Info: https://zonasystem.com/2018/12/transferir-roles-fsmo-windows-server-y-purgado-de-servicios-del-dominio.html
```ps
Get-ADDomain | Select-Object InfrastructureMaster, RIDMaster, PDCEmulator | Format-List
Get-ADForest | Select-Object DomainNamingMaster, SchemaMaster | Format-List
```

Get all Domain Controllers the domain.
```ps
Get-ADDomainController -Filter * | Select-Object HostName, IPv4Address, Enabled
```