# Migrate users from an old domain to a new domain

Migrate a list of users from an old domain to a new domain Active Directory.

- **Export-ADUsers-By-DNs.ps1**: Export Active Directory users by set one or more "distinguishedName" as searchbase, you can use one OU or multiple OUs and export the list of users to a csv file.

- **Import-ADUsers-To-NewDomain.ps1**: Import a list of users from a CSV file from the old domain to the new domain, replacing the new domain in the "UserPrincipalName" field.