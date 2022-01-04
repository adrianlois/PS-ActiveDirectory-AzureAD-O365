Import-Module ActiveDirectory

$groupToCopy = (Get-ADgroupMember "SourceGroup")
$targetGroup ="DestinationGroup"

foreach ( $user in $groupToCopy ) {
    $username = $user.SamAccountName
    Add-ADGroupMember -identity "$targetGroup" -Members $username
}