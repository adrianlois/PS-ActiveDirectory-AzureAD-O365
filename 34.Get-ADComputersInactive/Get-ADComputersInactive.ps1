Get-ADComputer -filter * -Proper Name, DisplayName, SamAccountName, lastlogondate, PasswordLastSet |`
Format-Table Name, DisplayName, SamAccountName, lastlogondate, PasswordLastSet |`
Export-Csv -Path "%USERPROFILE%\Desktop" -Encoding UTF8 -NoTypeInformation