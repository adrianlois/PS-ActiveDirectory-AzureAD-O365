Function Get-ADUsers-Inactivity-LastDays {

    [CmdletBinding()]
    param (
        [Parameter(Mandatory)]
        [int]$DaysInactive,
        [Parameter(Mandatory)]
        [string]$ExportPath
    )

    $Time = (Get-Date).Adddays(-($DaysInactive))
    
    Get-ADUser -Filter {LastLogonTimeStamp -lt $Time} -Properties * | `
    Where-Object {$_.Enabled -like "True"} | `
    Select-Object Name,EmailAddress,DistinguishedName,SamAccountName,PasswordNeverExpires,Enabled,whenCreated,LastLogonDate | `
    Export-Csv -Path $ExportPath -Delimiter ';' -NoTypeInformation
}

# Get-ADUsers-Inactivity-LastDays -DaysInactive 90 -ExportPath "%USERPROFILE%\Desktop\ADUsersLastLogon.csv"