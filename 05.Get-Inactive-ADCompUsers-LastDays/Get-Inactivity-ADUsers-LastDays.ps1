Function Get-ADUsers-Inactivity-LastDays {

    [CmdletBinding()]
    param (
        [Parameter(Mandatory)]
        [int]$DaysInactive,
        [Parameter(Mandatory)]
        [string]$ExportPath
    )

    $Time = (Get-Date).Adddays(-($DaysInactive))
    
    Get-ADUser -Filter * -Properties * | `
	Select-Object Name,EmailAddress,DistinguishedName,SamAccountName,PasswordNeverExpires,Enabled,whenCreated,LastLogonDate | `
	Where-Object { ($_.LastLogonDate -lt $Time) -and ($_.Enabled -like "True") } | `
    Export-Csv -Path $ExportPath -Delimiter ';' -NoTypeInformation -Encoding UTF8
}

# Get-ADUsers-Inactivity-LastDays -DaysInactive 90 -ExportPath "%USERPROFILE%\Desktop\ADUsersLastLogon.csv"