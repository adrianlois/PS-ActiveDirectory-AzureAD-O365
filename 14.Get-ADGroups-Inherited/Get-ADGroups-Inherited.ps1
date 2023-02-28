function Get-InheritedGroups {

    param (
        [Parameter(Mandatory=$True)]
        [string]$User
    )

    $grpsAD1 = (Get-ADPrincipalGroupMembership -Identity "$user").SamAccountName 
    Write-Host "$grpsAD1"

    # TODO: if exist check membership group
    foreach ($grpAD1 in $grpsAD1) {
        (Get-ADPrincipalGroupMembership -Identity "$grpAD1").SamAccountName

        Write-Output "----- 1 -----"
        Write-Output "$grpAD1"

        # TODO: if exist check membership group
        foreach ($grpAD2 in $grpAD1) {
            (Get-ADPrincipalGroupMembership -Identity $grpAD2).SamAccountName

            Write-Output "----- 2 -----"
            Write-Output "    $grpAD1 -> $grpAD2"

            # TODO: if exist check membership group
            foreach ($grpAD3 in $grpAD2) {
                (Get-ADPrincipalGroupMembership -Identity $grpAD2).SamAccountName

                Write-Output "----- 3 -----"
                Write-Output "       $grpAD2 -> $grpAD3"
            }
        }
    }
}

<#
String 1.2.840.113556.1.4.1941 -> LDAP_MATCHING_RULE_IN_CHAIN: Get inherited memebership groups.
- memberOf: All members of specified group, including due to group nesting.
- member: All groups specified user belongs to, including due to group nesting.
    Get-ADGroup -LDAPFilter "(memberOf:1.2.840.113556.1.4.1941:= cn=Test,ou=East,dc=Domain,dc=com)" | Select-Object DistinguishedName,Name | Format-Table -AutoSize
#>

<#
Another similar path using the Get-ADObject cmdlet in a recursive (only shows the users and groups of the last inheritance).
    $adgrupo = Get-ADGroup "Domain Admins"
    Get-ADObject -Filter {memberOf -RecursiveMatch $adgrupo.DistinguishedName}
#>