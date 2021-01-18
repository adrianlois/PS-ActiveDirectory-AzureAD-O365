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

# member:1.2.840.113556.1.4.1941 -> Get inherited memebership groups
# Get-ADGroup -LDAPFilter "(member:1.2.840.113556.1.4.1941:=CN=User IT,OU=Test,OU=Users,OU=DC=domain,DC=local)" | Select-Object DistinguishedName,Name | Format-Table -AutoSize
