# Get-ADGroups-Inherited
#### Get up to 3 levels of nested inheritances in Active Directory groups by giving a specific user or group.

**memberOf** will only check direct attributes, so AD will only return information back to based on direct attribute checks.

To get a recursive search, or to have AD check relations, extra properties need to be included to the filter. In this case, the string 1.2.840.113556.1.4.1941 will need to be added. According to Microsoft:

The string **1.2.840.113556.1.4.1941** specifies **LDAP_MATCHING_RULE_IN_CHAIN**. This applies only to DN attributes. This is an extended match operator that walks the chain of ancestry in objects all the way to the root until it finds a match. This reveals group nesting. It is available only on domain controllers with Windows Server 2003 SP2 or Windows Server 2008 (or above).

For more information, see the following from Technet:
- http://social.technet.microsoft.com/wiki/contents/articles/5392.active-directory-ldap-syntax-filters.aspx
- https://devblogs.microsoft.com/scripting/active-directory-week-explore-group-membership-with-powershell

String 1.2.840.113556.1.4.1941 -> LDAP_MATCHING_RULE_IN_CHAIN: Get inherited memebership groups.
- **memberOf**: All members of specified group, including due to group nesting.
- **member**: All groups specified user belongs to, including due to group nesting.

```ps
Get-ADGroup -LDAPFilter "(memberOf:1.2.840.113556.1.4.1941:= cn=Test,ou=East,dc=Domain,dc=com)" | Select-Object DistinguishedName, Name | Format-Table -AutoSize
```

Another similar path using the Get-ADObject cmdlet in a recursive (only shows the users and groups of the last inheritance).
```ps
$adgrupo = Get-ADGroup "Domain Admins"
Get-ADObject -Filter {memberOf -RecursiveMatch $adgrupo.DistinguishedName}
```