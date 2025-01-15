# Migrate-UserProfile
#### Migrate user profiles

- Migrate/Copy the most relevant directories from a local or domain user profile to a new computer using ROBOCOPY tool.

Load function **Migrate-UserProfile.ps1**. Usage example:
```
Migrate-UserProfile -PCSrc "PC1" -PCDst "PC2" -User "USER"
```

Load functions **.\Migrate-UserProfile-Form.ps1** and execute function:

![migrate-userprofile-form](https://raw.githubusercontent.com/adrianlois/PowerShell-ActiveDirectory-AzureAD-O365-EXO/master/12.Migrate-UserProfile/Migrate-UserProfile-Form.png)