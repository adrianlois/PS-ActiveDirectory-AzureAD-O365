# Office 365: PowerShell Module MSOnline

Collection of use cases, mainly for gathering information using the *MSOnline* modules of Office 365 and *ExchangeOnlineManagement* of Exchange Online.

- [Office 365: PowerShell Module MSOnline](#office-365-powershell-module-msonline)
    - [Install \& Import Module MSOnline](#install--import-module-msonline)
    - [Initiate a connection MSOnline](#initiate-a-connection-msonline)
    - [Initiate a connection by using a credential object MSOnline](#initiate-a-connection-by-using-a-credential-object-msonline)
    - [Get licensed Office 365 users](#get-licensed-office-365-users)
    - [List of users without a license](#list-of-users-without-a-license)
    - [List of deleted accounts](#list-of-deleted-accounts)
    - [List the time of the last password change for Office 365 users](#list-the-time-of-the-last-password-change-for-office-365-users)
    - [List the active (enabled) accounts](#list-the-active-enabled-accounts)
    - [List the disabled accounts](#list-the-disabled-accounts)
    - [Get list Azure tenant users that have not been synced from on-premises Active Directory Domain Services (cloud users) via Azure Active Directory Sync (Azure AD Connect)](#get-list-azure-tenant-users-that-have-not-been-synced-from-on-premises-active-directory-domain-services-cloud-users-via-azure-active-directory-sync-azure-ad-connect)
    - [Check if the user is cloud-native or synced from on-prem AD](#check-if-the-user-is-cloud-native-or-synced-from-on-prem-ad)
    - [Get list of users who haven’t changed their passwords for more than 90 days](#get-list-of-users-who-havent-changed-their-passwords-for-more-than-90-days)
- [Exchange Online: PowerShell Module ExchangeOnlineManagement](#exchange-online-powershell-module-exchangeonlinemanagement)
    - [Install \& Import Module ExchangeOnlineManagement](#install--import-module-exchangeonlinemanagement)
    - [Initiate a connection ExchangeOnlineManagement](#initiate-a-connection-exchangeonlinemanagement)
    - [Initiate a connection ExchangeOnlineManagement (PowerShell 7 exclusive connection method)](#initiate-a-connection-exchangeonlinemanagement-powershell-7-exclusive-connection-method)
    - [Get a summary list of all the mailboxes in your organization](#get-a-summary-list-of-all-the-mailboxes-in-your-organization)
    - [List all SMTP email addresses (primary and secondary)](#list-all-smtp-email-addresses-primary-and-secondary)
    - [Get a list of shared mailboxes members and permissions](#get-a-list-of-shared-mailboxes-members-and-permissions)
    - [Disconnect Exchange Online session](#disconnect-exchange-online-session)
    - [ExchangePowerShell Category](#exchangepowershell-category)

### Install & Import Module MSOnline
```ps
Install-Module MSOnline
Import-Module MSOnline
```

### Initiate a connection MSOnline
```ps
Connect-MsolService
```

### Initiate a connection by using a credential object MSOnline
```ps
$MSOCred = Get-Credential
Connect-MsolService -Credential $MSOCred
```

### Get licensed Office 365 users
```ps
Get-MsolUser | Select-Object UserPrincipalName, DisplayName, PhoneNumber, Department, UsageLocation| Export-CSV O365_UserList.csv –NoTypeInformation
```

### List of users without a license
```ps
Get-MsolUser –UnlicensedUsersOnly
```

### List of deleted accounts
```ps
Get-MsolUser -ReturnDeletedUsers | Format-List UserPrincipalName,ObjectID
```

### List the time of the last password change for Office 365 users
```ps
Get-MsolUser -All | Select-Object DisplayName, LastPasswordChangeTimeStamp
```

### List the active (enabled) accounts
```ps
Get-MsolUser -EnabledFilter EnabledOnly -All
```

### List the disabled accounts
```ps
Get-MsolUser -EnabledFilter DisabledOnly –All
```

###  Get list Azure tenant users that have not been synced from on-premises Active Directory Domain Services (cloud users) via Azure Active Directory Sync (Azure AD Connect)
```ps
Get-MsolUser -All -Synchronized:$False
```

###  Check if the user is cloud-native or synced from on-prem AD
```ps
$upn = “youraccount@o365.onmicrosoft.com”

if ([bool](Get-MsolUser -Synchronized).UserPrincipalName -contains $upn) {
    Write-Host -foregroundcolor Green $upn " is on-prem Synchronized User"
} else {
    Write-Host -foregroundcolor Red $upn " is NOT Synchronized User (cloud only user)"
}
```

### Get list of users who haven’t changed their passwords for more than 90 days
```ps
Get-MsolUser | Where-Object { $.LastPasswordChangeTimestamp -lt (Get-Date).AddDays(-90)} | Select-Object DisplayName,UserPrincipalName,LastPasswordChangeTimestamp,Licenses,PasswordNeverExpires | Format-Table
```

---

# Exchange Online: PowerShell Module ExchangeOnlineManagement
### Install & Import Module ExchangeOnlineManagement
```ps
Install-Module ExchangeOnlineManagement
Import-Module ExchangeOnlineManagement
```

### Initiate a connection ExchangeOnlineManagement
```ps
Connect-ExchangeOnline -UserPrincipalName username@domain.onmicrosoft.com
```

### Initiate a connection ExchangeOnlineManagement (PowerShell 7 exclusive connection method)
```ps
Connect-ExchangeOnline -UserPrincipalName username@domain.onmicrosoft.com -InlineCredential
```

### Get a summary list of all the mailboxes in your organization
```ps
Get-Mailbox -RecipientTypeDetails SharedMailbox -ResultSize Unlimited | Select-Object PrimarySmtpAddress,DisplayName | Export-Csv SharedFolders.csv  -NoTypeInformation SharedMailboxUsers.csv  -NoTypeInformation 
```

### List all SMTP email addresses (primary and secondary)
SMTP secundary is written in lowercase letters because it’s not the primary SMTP. The Primary SMTP is written in uppercase letters.
```ps
Get-Mailbox -ResultSize Unlimited | Select-Object DisplayName,PrimarySmtpAddress, @{Name="EmailAddresses";Expression={($_.EmailAddresses | Where-Object {$_ -clike "smtp*"} | ForEach-Object {$_ -replace "smtp:",""}) -join ","}} | Sort-Object DisplayName
```

### Get a list of shared mailboxes members and permissions
```ps
Get-Mailbox -RecipientTypeDetails SharedMailbox -ResultSize Unlimited | Get-MailboxPermission | Select-Object Identity,User,AccessRights,UserPrincipalName,LitigationHold,IsLicensed,AuditEnabled,HideFromAddressList | Where-Object {($_.user -like '*@*')} | Export-Csv SharedMailbox.csv -NoTypeInformation 
```
- **AccessRights**: permissions that the security principal has on the mailbox.
- **LitigationHold**: verify a mailbox on Litigation Hold.
- **AuditEnabled**: verify mailbox auditing is enabled.
- **HideFromAddressList**: control visibility in address lists.

### Disconnect Exchange Online session
```ps
Disconnect-ExchangeOnline -Confirm:$False -InformationAction Ignore -ErrorAction SilentlyContinue
```

### ExchangePowerShell Category

| Category | Info |
|----------|------|
| Active Directory | https://learn.microsoft.com/en-us/powershell/module/exchange/?view=exchange-ps#active-directory |
| Users and groups | https://learn.microsoft.com/en-us/powershell/module/exchange/?view=exchange-ps#users-and-groups |
| Role based access control (RBAC) | https://learn.microsoft.com/en-us/powershell/module/exchange/?view=exchange-ps#role-based-access-control |
|Policy and compliance | https://learn.microsoft.com/en-us/powershell/module/exchange/?view=exchange-ps |
| Antispam and Antimalware | https://learn.microsoft.com/en-us/powershell/module/exchange/?view=exchange-ps#antispam-antimalware |
| Defender for Office 365 | https://learn.microsoft.com/en-us/powershell/module/exchange/?view=exchange-ps#defender-for-office-365 |
