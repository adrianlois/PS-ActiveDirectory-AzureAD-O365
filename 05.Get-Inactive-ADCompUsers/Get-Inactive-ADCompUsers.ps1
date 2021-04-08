Import-Module ActiveDirectory

function Get-InactiveADComputers {

    [CmdletBinding()]
    param (
        [Parameter(Mandatory)]
        [int]$DaysInactive
        [Parameter(Mandatory)]
        [string]$ExportPath
    )

    $Time = (Get-Date).Adddays(-($DaysInactive))

    Get-ADComputer -Filter {LastLogonTimeStamp -lt $Time} -Properties LastLogonTimeStamp | `
    Select-Object Name,@{Name="Stamp";Expression={[DateTime]::FromFileTime($_.lastLogonTimestamp)}} | `
    Export-Csv $ExportPath
}

function Get-InactiveADUsers {

    [CmdletBinding()]
    param (
        [Parameter(Mandatory)]
        [int]$DaysInactive
        [Parameter(Mandatory)]
        [string]$ExportPath
    )

    Search-ADAccount -AccountInactive -TimeSpan $DaysInactive | Sort -Property LastLogonDate | `
    Format-Table SamAccountName, LastLogonDate -AutoSize | `
    Export-Csv $ExportPath

    <# another way
      $Time = (Get-Date).Adddays(-($DaysInactive))
      Get-ADUser -Filter * -Properties * | Where-Object {$_.LastLogonDate -le $Time} | Select UserPrincipalName | Export-Csv $ExportPath
    #>
}
