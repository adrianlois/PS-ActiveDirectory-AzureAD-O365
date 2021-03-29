# ExportAll-ADObjects
#### Export all Active Directory objects in csv format (computers, groups and users).

Set with a switch parameter whether or not to export Computers, Groups or Users object types. The export path is mandatory

Example: Export all the users and groups in the directory
```
.\ExportAll-ADObjects.ps1 -ADGroups -ADUsers -ExportPath "C:\Users\adrian\Desktop\ExportAD"
```

- *Member, MemberOf*: Expand all members and members of users or groups separated by semicolon (;) and show only their name.
- *ExpirationDate, msDS-UserPasswordExpiryTimeComputed*: Convert to date format to a human format dd/mm/yyyy.