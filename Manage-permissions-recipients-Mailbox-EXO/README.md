# Manage-permissions-recipients-Mailbox-EXO

#### Manage permissions for recipients in Exchange Online. Add multiple users to a shared mailbox.

Info: https://docs.microsoft.com/en-us/exchange/recipients-in-exchange-online/manage-permissions-for-recipients

1. Install and import Module "ExchangeOnlineManagement"
2. Connect Online Exchange with Powershell with or without MFA
3. Set variables and add users to a shared mailbox

#### Variables to Modify

- ***$MailboxIdentity = MailboxShared_Account:*** Shared mailbox account to delegate

- ***$MailboxDelegate = UPN_user1,UPN_user2,...:*** UPN of the users that will delegate (separated by commas (,) and single quote (') )

#### About the permits

- *Send on Behalf*: https://docs.microsoft.com/en-us/powershell/module/exchange/mailboxes/set-mailbox
- *Send As*: https://docs.microsoft.com/en-us/powershell/module/exchange/mailboxes/add-recipientpermission
- *Full Access*: https://docs.microsoft.com/en-us/powershell/module/exchange/mailboxes/add-mailboxpermission
