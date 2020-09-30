# Change-Attributes-UserAD
#### Modify Active Directory User Account Attributes, loading a list of users from a CSV file

List of attributes available to replace or add in script hashtable @{...;...}.

```
Get-ADUser -Identity $samAccountName -Properties *
```
