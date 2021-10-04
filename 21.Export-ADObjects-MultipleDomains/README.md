# Export-ADObjects-MultipleDomains
## FullExport-ADObjects.ps1
#### Get all objects from all available Active Directory domains and export them in a CSV format (users, groups and computers).

Set with a switch parameter whether or not to export Users, Groups or Computers object types. The export path is mandatory, a second export path would be an optional parameter.

The only thing that needs to be modified in the script are the DC domain controllers and their corresponding domains. In the case of having more than one domain controller for each domain, i recommend indicating the PDC (Primary Domain Controller). It is necessary to adapt the variable $csv to real values to perform the queries to the Active Directory domains. 

In case you do not have multiple domains and have a single domain simply delete the rows and set up a single row as in the following example.
```
"dc";"domain";"name"
"DC01DOM1.domain.local";"DC=domain,DC=local";"Domain"*
```

Example 1: Export Active Directory objects users and groups 
```powershell
FullExport-ADObjects -ADUsers -ADGroups -CsvPath "C:\Users\adrian\Desktop\ExportAD"
```
Example 2: Export Active Directory all objects (users, groups and computers) and the files are exported locally and then moved to another path
```powershell
FullExport-ADObjects -ADAll -CsvPath "C:\Users\adrian\Desktop\ExportAD" -DestinationPath "\\server\shared\"
```

- *Member, MemberOf*: Expand all members and members of users or groups separated by semicolon ( ; ) and show only their name.
- *ExpirationDate, msDS-UserPasswordExpiryTimeComputed*: Convert to date format to a human format dd/mm/yyyy.

## Troubleshooting for invalid enumeration context error
When we try to enumerate too many Active Directory objects **using pipelines** with cmdlets (Get-ADUser, Get-ADComputer, Get-ADGroup) we may encounter the following error.
```
The server has returned the following error: invalid enumeration context.
(El servidor ha devuelto el siguiente error: contexto de enumeración no válido.)
```
Summarizing, this is due to a maximum time exceeded between the request of new pages to the Active Directory Web Services (ADWS), this generates very high time to then channel the results object to object to the next pipeline, if it is the obtaining of many objects in the same query and exceeds 30 minutes (MaxEnumContextExpiration), then the Enumeration Context Expires.

> *MaxEnumContextExpiration* default parameter in *C:\Windows\ADWS\Microsoft.ActiveDirectory.WebServices.exe.config*, change the default value of this paremeter is strongly discouraged).

### Recommended solution

Store your Active Directory objects in a variable in memory, and then send them down the pipe using the variable. This will decrease the times considerably by avoiding the excess 30 minutes of querying.

References explained:

- https://social.technet.microsoft.com/wiki/contents/articles/32418.active-directory-troubleshooting-server-has-returned-the-following-error-invalid-enumeration-context.aspx
- Paging Search Results: https://docs.microsoft.com/es-es/previous-versions/windows/desktop/ldap/paging-search-results?redirectedfrom=MSDN


## Set-FQDNToCsv.ps1

Use this script as an example to add a new column to an existing csv file.


## Get-AddFQDN-ADComputers.ps1

Export all Active Directory equipment type objects. Use this script as an example to replace a column and its values in all objects, finally export everything to a single csv file.

For NON WINDOWS computers that do not have value set in the attribute "DNSHostName" we concatenate the fields Name, Domain and DistinguishedName to create it completely (FQDN) and then create a new csv file and replace the DNSHostName attribute with the concatenated FQDN field for all computers objects.
