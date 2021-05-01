Import-Module ActiveDirectory

$objSID = New-Object System.Security.Principal.SecurityIdentifier ("SIDtoSamAccountName")
$objUser = $objSID.Translate([System.Security.Principal.NTAccount])
$objUser.Value
