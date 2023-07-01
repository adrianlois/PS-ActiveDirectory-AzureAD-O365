$NewUsersList = Import-CSV "Users_List.csv" -Delimiter ";"

ForEach ($User in $NewUsersList) {
	$Firstname = $User.Firstname
	$Surname = $User.Surname
	$DisplayName=$User.DisplayName
	$SamAccountName=$User.SamAccountName
	$UserPrincipalName= $User.UserPrincipalName -Replace "OldDomain","NewDomain"
	$UserEmail=$User.Email

    New-ADUser -PassThru -Path "DC=NewDomain,DC=local" `
        -AccountPassword (ConvertTo-SecureString UserPasswordTemp -AsPlainText -Force) `
        -CannotChangePassword $False -DisplayName $DisplayName -GivenName $Firstname `
        -Name $DisplayName -SamAccountName $SamAccountName -Surname $Surname `
        -Email $UserEmail -UserPrincipalName $UserPrincipalName -Enabled $True
}