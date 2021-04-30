# ADObjects-ExportAll
#### Get all objects from all available Active Directory domains and export them in a CSV format (computers, groups and users).

Set with a switch parameter whether or not to export Computers, Groups or Users object types. The export paths are mandatory.

It is necessary to adapt the variable $csv to real values to perform the queries to the Active Directory domains. dc,domain,name *("DC01DOM1.domain.local";"DC=domain,DC=local";"Domain")*

Example 1: Export Active Directory objects users and groups 
```
.\ADObjects-ExportAll.ps1 -ADUsers -ADGroups -CsvPath "C:\Users\adrian\Desktop\ExportAD" -DestinationPath "\\server\shared\"
```
Example 2: Export Active Directory all objects (computers, groups and users)
```
.\ADObjects-ExportAll.ps1 -ADAll -CsvPath "C:\Users\adrian\Desktop\ExportAD" -DestinationPath "\\server\shared\"
```

- *Member, MemberOf*: Expand all members and members of users or groups separated by semicolon ( ; ) and show only their name.
- *ExpirationDate, msDS-UserPasswordExpiryTimeComputed*: Convert to date format to a human format dd/mm/yyyy.