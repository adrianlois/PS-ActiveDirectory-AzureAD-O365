# Get ADUser by Email Address

Obtain a user's property information from domain email. And get from an array of emails.

```powershell
Get-ADUser -Filter {EmailAddress -eq 'user1@email.com'} -Properties *
```
