# Set distinguishedName as searchbase, you can use one OU or multiple OUs
# Or use the root domain like "DC=domain,DC=local"
$DNs = @(
    "OU=Administration,OU=Clients,DC=domain,DC=local"
    "OU=Sales,DC=domain,DC=local"
    "OU=Finance,DC=domain,DC=local"
)

# Create empty array
$AllADUsers = @()

# Loop through every DN
foreach ($DN in $DNs) {
    $Users = Get-ADUser -SearchBase $DN -Filter * -Properties * 

    # Add users to array
    $AllADUsers += $Users
}

# Create list
$AllADUsers | Sort-Object Name | Select-Object `
    @{Label = "Firstname"; Expression = { $_.GivenName } },
    @{Label = "Surname"; Expression = { $_.Surname } },
    @{Label = "DisplayName"; Expression = { $_.DisplayName } },
    @{Label = "SamAccountName"; Expression = { $_.SamAccountName } },
    @{Label = "UserPrincipalName"; Expression = { $_.UserPrincipalName } },
    @{Label = "Email"; Expression = { $_.Mail } } | `

# Export report to CSV file
Export-Csv -Encoding UTF8 -Path $Csvfile -NoTypeInformation -Delimiter ";"