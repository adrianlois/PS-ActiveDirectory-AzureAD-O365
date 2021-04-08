# Change-Attributes-ADUsers
#### Modify Active Directory User Account Attributes, loading a list of users from a CSV file

The script contains examples with string and boolean values.

List of attributes available to replace or add in script hashtable @{...;...}.

```
Get-ADUser -Identity $samAccountName -Properties *
```
