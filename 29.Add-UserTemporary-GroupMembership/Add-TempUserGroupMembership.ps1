Function Add-TempUserGroupMembership {
    [CmdletBinding()]
    Param (
        [String]$IdentityGroup,
        [String]$MemberUser,
        [Switch]$Minutes,
        [Switch]$Hours,
        [Switch]$Days
    )

    if ($Minutes) { $ttl = New-TimeSpan -Minutes $Minutes }
    if ($Hours) { $ttl = New-TimeSpan -Hours $Hours }
    if ($Days) { $ttl = New-TimeSpan -Days $Days }

    Add-ADGroupMember -Identity $IdentityGroup -Members $MemberUser -MemberTimeToLive $ttl
}
Add-TempUserGroupMembership -IdentityGroup "grp.admins.temp" -MemberUser "TestUser1" -Hours "8"