## 05.Get-Inactive-ADCompUsers-LastDays

### **Get-Inactive-ADCompUsers**

Get objects users and computers inactive in Active Directory with PowerShell script and export to a csv file.

#### Functions
**Get-InactiveADComputers**: Get inactive computers from Active Directory by set the last number days. In a commented manner reference is also made to another path using the *Search-ADAccount* cmdlet to reach the same result)

Inactive computers last 90 days
```ps
Get-InactiveADComputers -DaysInactive 90 -ExportPah "C:\path\report-computers.csv"
```
**Get-InactiveADUsers**: Get inactive accounts users from Active Directory by set the last number days.

Inactive computers last 60 days
```ps
Get-InactiveADUsers -DaysInactive 60 -ExportPah "C:\path\report-users.csv"
```

### **Get-Inactivity-ADUsersLastLogon.ps1**

Get the last login of Active Directory users (set the $DaysInactive variable). Search only for enabled AD users and export the output to a csv file.
```ps
Get-Inactivity-ADUsersLastLogon -DaysInactive 90 -ExportPath "%USERPROFILE%\Desktop\ADUsersLastLogon.csv"
```

## Definition of timestamps attributes

- **LastLogon**: When a user logs in, this attribute is updated only in the DC that has provided the authentication, it is not replicated. This attribute is useful to know in which services the user has or has not logged in.

- **LastLogonTimeStamp**: This attribute is similar to "LastLogon" one except that this data is replicated on all domain controllers in a domain. Although to avoid an excessive number of calls between DCs each time a user logs in, the need or not for this synchronization is calculated by means of a third attribute, [ms-DS-Logon-Time-Sync-Interval](https://learn.microsoft.com/en-us/windows/win32/adschema/a-msds-logontimesyncinterval) (which by default is 14 days) and a number of additional calculations. This value can also be used to identify inactive accounts, although its format (NT Time) makes it not very convenient to use.

- **LastLogonDate**: Finally we have "LastLogonDate", this will be the most useful attribute since although it is not a replicated value if it calculates the value from LastLogonTimeStamp which yes it is replicated.
