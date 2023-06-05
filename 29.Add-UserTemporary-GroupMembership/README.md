# Time-Based (Temporary) Group Membership in Active Directory

This feature is called Temporary Group Membership (Time Based). This feature can be used when you need to temporarily grant a user some authority based on AD security group membership. After the specified time has elapsed, the user will be automatically removed from the security group (without administrator intervention).

> Cannot disable PAM (Privileged Access Management) after this feature has been enabled.

### Prerequisites

Check if *"Privileged Access Management Feature"* is enabled in the current forest.

If the value of the *"EnableScopes"* parameter parameter is empty it means that Privileged Access Management Feature is not enabled for this forest.
```ps
Get-ADOptionalFeature -Filter "Name -eq 'Privileged Access Management Feature'" | Select-Object "EnabledScopes"
```

Enable the feature "Privileged Access Management Feature" and specify your forest name *"domain.local"*.
```ps
Enable-ADOptionalFeature "Privileged Access Management Feature" -Scope ForestOrConfigurationSet -Target "domain.local"
```

### Example in one line

In the following example in one line, you will add to the group "grp.admins.temp" the user with SamAccountName "TestUser1".

New-TimeSpan support: -Minutes, -Hours, -Days.
```ps
Add-ADGroupMember -Identity "grp.admins.temp" -Members test1 -MemberTimeToLive (New-TimeSpan -Hours 8)
```

Check how much time a user will be a group member
```ps
Get-ADGroup "grp.admins.temp" -Property member –ShowMemberTimeToLive
```

### Function Add-UserTempGroupMembership

- *IdentityGroup*: AD group name for privileged membership 
- *MemberUser*: AD user to add to the privileged group
- *Minutes, Hours, Days*: Depending on the time we need to grant, we can choose one of the three parameters by setting it in minutes, hours or days.