function Get-InactiveADComputers {

    [CmdletBinding()]
    param (
        [Parameter(Mandatory=$True)]
        [int]$DaysInactive,
        [Parameter(Mandatory=$True)]
        [string]$ExportPath
    )

    $Time = (Get-Date).Adddays(-($DaysInactive))

    Get-ADComputer -Filter {LastLogonTimeStamp -lt $Time} -Properties LastLogonTimeStamp | `
    Select-Object Name,@{Name="Stamp";Expression={[DateTime]::FromFileTime($_.lastLogonTimestamp)}} | `
    Export-Csv -Path $ExportPath -Delimiter ';' -NoTypeInformation

<#
Another path using the Search-ADAccount cmdlet to reach the same result.

    Search-ADAccount -AccountInactive -TimeSpan "$DaysInactive" | `
    Where-Object {($_.ObjectClass -eq "computer") -and ($_.Enabled -eq $True)} | `
    Sort-Object -Property LastLogonDate | `
    Format-Table Name, LastLogonDate -AutoSize | `
    Export-Csv -Path $ExportPath -Delimiter ';' -NoTypeInformation
#>
}

# Get-InactiveADComputers -DaysInactive 90 -ExportPath "%USERPROFILE%\Desktop\ADUsersLastLogon.csv"

function Get-InactiveADUsers {

    [CmdletBinding()]
    param (
        [Parameter(Mandatory=$True)]
        [int]$DaysInactive,
        [Parameter(Mandatory=$True)]
        [string]$ExportPath
    )

    Search-ADAccount -AccountInactive -TimeSpan "$DaysInactive" | `
    Where-Object {($_.ObjectClass -eq "user") -and ($_.Enabled -eq $True)} | `
    Sort-Object -Property LastLogonDate | `
    Format-Table SamAccountName, LastLogonDate -AutoSize | `
    Export-Csv -Path $ExportPath -Delimiter ';' -NoTypeInformation
}

# Get-InactiveADUsers -DaysInactive 90 -ExportPath "%USERPROFILE%\Desktop\ADUsersLastLogon.csv"
