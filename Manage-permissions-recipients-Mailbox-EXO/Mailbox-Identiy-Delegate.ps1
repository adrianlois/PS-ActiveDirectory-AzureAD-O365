# Install and import module ExchangeOnlineManagement
Install-Module -Name ExchangeOnlineManagement
Import-Module -Name ExchangeOnlineManagement

# Connect Exchange Online without MFA
$UserCredential = Get-Credential
Connect-ExchangeOnline -Credential $UserCredential -ShowProgress $true

# Connect Exchange Online with MFA (UPN: User Principal Name - user@domain.com)
Connect-ExchangeOnline -UserPrincipalName "user@domain.com" -ShowProgress $true

# You are logged on to a computer as a user in the SSO domain 
Connect-EXPOPSSession
# New-ExoPSSession

# Variables
$MailboxIdentity = "<MailboxShared_Account>"
$MailboxDelegate = '<UPN_user1>','<UPN_user2>','<UPN_user3>','<UPN_user4>'

ForEach ($User in $MailboxDelegate) {

    # Full Access
    Add-MailboxPermission `
        -Identity $MailboxIdentity `
        -User $User `
        -AccessRights FullAccess `
        -InheritanceType All `
        -Confirm:$false

    # Send As
    Add-RecipientPermission `
        -Identity $MailboxIdentity `
        -Trustee $User `
        -AccessRights SendAs `
        -Confirm:$false
    
    # Send on Behalf
    Set-Mailbox "$MailboxIdentity" `
        -GrantSendOnBehalfTo @{add="$User"} `
        -Confirm:$false
}

# Replace existing delegates: <UPN_user1> or "<UPN_user1>","<UPN_user2>",...
# Add or remove delegates without affecting other delegates: @{Add="\<value1\>","\<value2\>"...; Remove="\<value1\>","\<value2\>"...}
# Remove all delegates: Use the value $null.
