Get-ADComputer -filter * -Proper Name, DisplayName, SamAccountName, lastlogondate, PasswordLastSet |`
ft Name, DisplayName, SamAccountName, lastlogondate, PasswordLastSet |`
Export-Csv -Path "%USERPROFILE%\Desktop" -Encoding UTF8 -NoTypeInformation