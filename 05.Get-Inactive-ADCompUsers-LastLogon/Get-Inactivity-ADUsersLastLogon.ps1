Function Get-Inactivity-ADUsersLastLogon {

    [CmdletBinding()]
    param (
        [Parameter(Mandatory=$True)]
        [int]$DaysInactive,
        [Parameter(Mandatory=$True)]
        [string]$ExportPath
    )

	$Time = (Get-Date).AddDays(-$DaysInactive)

	Get-ADUser -Filter * -Properties * | `
	Select-Object Name,EmailAddress,DistinguishedName,SamAccountName,PasswordNeverExpires,Enabled,whenCreated,LastLogonDate | `
	Where-Object { ($_.LastLogonDate -lt $Time) -and ($_.Enabled -like "True") } | `
	Sort-Object -Property LastLogonDate | `
    Export-Csv -Path $ExportPath -Delimiter ';' -NoTypeInformation -Encoding UTF8
}

# Get-Inactivity-ADUsersLastLogon -DaysInactive 90 -ExportPath "%USERPROFILE%\Desktop\ADUsersLastLogon.csv"