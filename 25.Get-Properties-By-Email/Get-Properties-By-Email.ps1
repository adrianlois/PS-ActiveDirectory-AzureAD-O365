Import-Module ActiveDirectory

$Emails = "user1@email.com","user2@email.com","user3@email.com","user4@email.com"

Foreach ($Email in $Emails) {
    Get-ADUser -Filter {EmailAddress -eq $Email} -Properties * | Select-Object EmailAddress, PasswordNeverExpires, Enabled | Export-Csv "Emails.csv" -NoTypeInformation -Append
}
