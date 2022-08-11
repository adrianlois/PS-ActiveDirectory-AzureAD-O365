# Get ADUser by Email Address

Get a AD user property information from domain email. And get from an array of emails.

```powershell
Get-ADUser -Filter {EmailAddress -eq 'user1@email.com'} -Properties *
```
