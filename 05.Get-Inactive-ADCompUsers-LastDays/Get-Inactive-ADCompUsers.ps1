function Get-InactiveADComputers {

    [CmdletBinding()]
    param (
        [Parameter(Mandatory)]
        [int]$DaysInactive,
        [Parameter(Mandatory)]
        [string]$ExportPath
    )

    $Time = (Get-Date).Adddays(-($DaysInactive))

    Get-ADComputer -Filter {LastLogonTimeStamp -lt $Time} -Properties LastLogonTimeStamp | `
    Select-Object Name,@{Name="Stamp";Expression={[DateTime]::FromFileTime($_.lastLogonTimestamp)}} | `
    Export-Csv $ExportPath
}

# Get-InactiveADComputers -DaysInactive 90 -ExportPath "%USERPROFILE%\Desktop\ADUsersLastLogon.csv"

function Get-InactiveADUsers {

    [CmdletBinding()]
    param (
        [Parameter(Mandatory)]
        [int]$DaysInactive,
        [Parameter(Mandatory)]
        [string]$ExportPath
    )

    Search-ADAccount -AccountInactive -TimeSpan $DaysInactive | Sort-Object -Property LastLogonDate | `
    Format-Table SamAccountName, LastLogonDate -AutoSize | `
    Export-Csv $ExportPath
}

# Get-InactiveADUsers -DaysInactive 90 -ExportPath "%USERPROFILE%\Desktop\ADUsersLastLogon.csv"
