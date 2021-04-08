# .\ExportAll-ADObjects.ps1 -ADComputers -ADGroups -ADUsers -ExportPath "C:\Users\adrian\Desktop\ExportAD"

# Load Active Directory module
Import-Module ActiveDirectory

param (
    [switch]$ADComputers=$False,
    [switch]$ADGroups=$False,
    [switch]$ADUsers=$False,
    [Parameter(Mandatory=$true)]
    [String]$ExportPath
)

function ADComputers {
	Get-ADComputer -Filter * -Properties * -SearchBase "DC=domain,DC=local" | `
	Select-Object Name,DNSHostName,IPv4Address,DistinguishedName,Enabled,whenCreated,LastLogonDate,`
	OperatingSystem,OperatingSystemVersion,ObjectClass,SID | `
	Export-Csv $ExportPath'\Computers.csv' -NoTypeInformation -Encoding UTF8
}

function ADGroups {
	Get-ADGroup -Filter * -Properties * -SearchBase "DC=domain,DC=local" | `
	Select-Object Name,Description,info,DistinguishedName,whenCreated,whenChanged,`
	@{Name='Member';Expression={($_.Member | % {(Get-ADObject $_).Name}) -join ";"}},`
	@{Name='MemberOf';Expression={($_.MemberOf | % {(Get-ADObject $_).Name}) -join ";"}},`
	GroupCategory,GroupScope,ObjectClass,SID | `
	Export-Csv $ExportPath'\Groups.csv' -NoTypeInformation -Encoding UTF8
}

function ADUsers {
	Get-ADUser -Filter * -Properties * -SearchBase "DC=domain,DC=local" | `
	Select-Object Name,SamAccountName,EmailAddress,DistinguishedName,Company,Enabled,SID,Country,co,Manager,`
	Department,Description,Office,OfficePhone,LastLogonDate,whenCreated,whenChanged,PasswordNeverExpires,`
	@{Name="ExpirationDate";Expression={[DateTime]::FromFileTime($_."msDS-UserPasswordExpiryTimeComputed")}},`
	@{Name="pwdLastSet";Expression={[DateTime]::FromFileTime($_.pwdLastSet)}},`
	@{Name='MemberOf';Expression= {($_.MemberOf | % {(Get-ADObject $_).Name}) -join ";"}} | `
	Export-Csv $ExportPath'\Users.csv' -NoTypeInformation -Encoding UTF8
}

if ($ADComputers) {ADComputers}
if ($ADGroups) {ADGroups}
if ($ADUsers) {ADUsers}