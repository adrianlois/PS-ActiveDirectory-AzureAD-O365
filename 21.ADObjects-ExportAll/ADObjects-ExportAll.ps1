# Import-Module ActiveDirectory
# .\ADObjects-ExportAll.ps1 -ADAll -CsvPath "C:\Users\adrian\Desktop\ExportAD" -DestinationPath "\\server\shared\"
# .\ADObjects-ExportAll.ps1 -ADUsers -ADGroups -CsvPath "C:\Users\adrian\Desktop\ExportAD" -DestinationPath "\\server\shared\"

param (
	[Parameter(Mandatory=$True)]
	[string]$CsvPath,
	[Parameter(Mandatory=$True)]
	[string]$DestinationPath,
	[switch]$ADComputers=$False,
	[switch]$ADGroups=$False,
	[switch]$ADUsers=$False,
	[switch]$ADAll=$False
)

# Replace domains. Add or remove row values for multiple domains 
$Csv = @"
"DC";"Domain";"Name"
"DC01DOM1.domain.local";"DC=domain,DC=local";"Domain"
"DC01DOM2.logistic.domain.local";"DC=logistic,DC=domain,DC=local";"Logistic"
"DC01DOM3.central.domain.local";"DC=central,DC=domain,DC=local";"Central"
"@ | ConvertFrom-CSV -Delimiter ';'

Function CheckFilesCsvTemp {
	$fileCsvTemp = "$CsvPath\*.csv"
	if (Test-Path $fileCsvTemp -PathType leaf) {
		Remove-Item -Path $fileCsvTemp -Force
	}
}

Function OutputBanner {
	Write-Host ">>>>>>>>>> Finished >>>>>>>>>>" -ForegroundColor White -BackgroundColor DarkCyan `n
}

Function ADComputers {

	$Csv | ForEach-Object {
		$DC = $_."DC"
		$Domain = $_."Domain"
		$Name = $_."Name"

		$FileCsvComputers = "$CsvPath\ADComputers_$Name.csv"
		Write-Host ":: Export data AD Computers ..." -ForegroundColor White -BackgroundColor DarkGreen

		$ADComputers = Get-ADComputer -Filter * -Server $DC -SearchBase $Domain -Properties `
			Name,DistinguishedName,DNSHostName,IPv4Address,Enabled,LastLogonDate,whenCreated,`
			OperatingSystem,OperatingSystemVersion,Location,ObjectClass,ObjectGUID,SID
		
		$ADComputers | Export-Csv $FileCsvComputers -NoTypeInformation -Encoding UTF8

		Copy-Item -Path $FileCsvComputers -Destination $DestinationPath -Force
		Remove-Item -Path $FileCsvComputers -Force
		OutputBanner
	}
}

Function ADGroups {

	$Csv | ForEach-Object {
		$DC = $_."DC"
		$Domain = $_."Domain"
		$Name = $_."Name"

		$FileCsvGroups = "$CsvPath\ADGroups_$Name.csv"
		Write-Host ":: Export data AD Groups ..." -ForegroundColor White -BackgroundColor DarkGreen

		$ADGroups = Get-ADGroup -Filter * -Server $DC -SearchBase $Domain -Properties *
		$ADGroups | Select-Object Name,Description,info,DistinguishedName,whenCreated,whenChanged,`
			@{Name='Member';Expression={($_.Member | % {(Get-ADObject $_).Name}) -join ";"}},`
			@{Name='MemberOf';Expression={($_.MemberOf | % {(Get-ADObject $_).Name}) -join ";"}},`
			GroupCategory,GroupScope,ObjectClass,ObjectGUID,SID | `
		
		Export-Csv $FileCsvGroups -NoTypeInformation -Encoding UTF8

		Copy-Item -Path $FileCsvGroups -Destination $DestinationPath -Force
		Remove-Item -Path $FileCsvGroups -Force
		OutputBanner
	}
}

Function ADUsers {

	$Csv | ForEach-Object {
		$DC = $_."DC"
		$Domain = $_."Domain"
		$Name = $_."Name"

		$FileCsvUsers = "$CsvPath\ADUsers_$Name.csv"
		Write-Host ":: Export data AD Users ..." -ForegroundColor White -BackgroundColor DarkGreen

		$ADUsers = Get-ADUser -Filter * -Server $DC -SearchBase $Domain -Properties *
		$ADUsers | Select-Object Name,SamAccountName,EmailAddress,DistinguishedName,Company,Enabled,Country,co,Manager,`
			Department,Description,Office,OfficePhone,LastLogonDate,whenCreated,whenChanged,PasswordNeverExpires,`
			@{Name="ExpirationDate";Expression={[DateTime]::FromFileTime($_."msDS-UserPasswordExpiryTimeComputed")}},`
			@{Name="pwdLastSet";Expression={[DateTime]::FromFileTime($_.pwdLastSet)}},`
			@{Name='MemberOf';Expression= {($_.MemberOf | % {(Get-ADObject $_).Name}) -join ";"}},`
			ObjectClass,ObjectGUID,SID | `

		Export-Csv $FileCsvUsers -NoTypeInformation -Encoding UTF8

		Copy-Item -Path $FileCsvUsers -Destination $DestinationPath -Force
		Remove-Item -Path $FileCsvUsers -Force
		OutputBanner
}
}

if ($ADAll) { 
	CheckFilesCsvTemp ; ADComputers ; ADGroups ; ADUsers 
} 
else {
	if ($ADComputers) { CheckFilesCsvTemp ; ADComputers }
	if ($ADGroups) { CheckFilesCsvTemp ; ADGroups }
	if ($ADUsers) { CheckFilesCsvTemp ; ADUsers }
}
