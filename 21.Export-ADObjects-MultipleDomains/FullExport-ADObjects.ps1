<#
.EXAMPLE
Full export. Single destination, without parameter -DestinationPath
   C:\PS> FullExport-ADObjects -ADFull -CsvPath "C:\Users\adrian\Desktop\ExportAD"

DestinationPath: Perform a full export by writing the files locally, once exported move these .csv files to a share.
   C:\PS> FullExport-ADObjects -ADFull -CsvPath "C:\Users\adrian\Desktop\ExportAD" -DestinationPath "\\server\shared\"

ADComputers, ADGroups, ADUsers: Boolean parameters, specify what you want to export. ADFull (implies all parameters).
   C:\PS> FullExport-ADObjects -ADUsers -ADGroups -CsvPath "C:\Users\adrian\Desktop\ExportAD" -DestinationPath "\\server\shared\"
#>

# Import-Module ActiveDirectory

Function FullExport-ADObjects {

	[cmdletbinding()]
	param (
		[Parameter(Mandatory=$True)]
		[string]$CsvPath,
		[string]$DestinationPath,
		[switch]$ADComputers=$False,
		[switch]$ADGroups=$False,
		[switch]$ADUsers=$False,
		[switch]$ADFull=$False
	)

$ErrorActionPreference = "Stop"

# Replace domains. Add or remove row values for multiple domains. In case of a single domain set only one row and remove the rest of rows.
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
		Write-Host "<<< Finished OK! >>>" -ForegroundColor White -BackgroundColor DarkCyan `n
	}

	Function ADComputers {
	
		$Csv | ForEach-Object {
			$DC = $_."DC"
			$Domain = $_."Domain"
			$Name = $_."Name"

			$FileCsvComputers = "$CsvPath\ADComputers_$Name.csv"
			Write-Host ":: Export objects type AD Computers - Domain $Name" -ForegroundColor White -BackgroundColor DarkGreen
            
			$ADComputers = Get-ADComputer -Filter * -Server $DC -SearchBase $Domain -Properties `
				Name,DistinguishedName,DNSHostName,IPv4Address,Enabled,LastLogonDate,whenCreated,`
				OperatingSystem,OperatingSystemVersion,Location,ObjectClass,ObjectGUID,SID
			$ADComputers | Export-Csv $FileCsvComputers -NoTypeInformation -Encoding UTF8

			if ($DestinationPath.Length -ne 0) {
				Copy-Item -Path $FileCsvComputers -Destination $DestinationPath -Force
				Remove-Item -Path $FileCsvComputers -Force
                		Write-Host " [OK] Moved export file:" -ForegroundColor Green
				Write-Host " $FileCsvComputers --> $DestinationPath\ADComputers_$Name.csv" -ForegroundColor Yellow
			}
			else {
                		Write-Host " [OK] Path export file:" -ForegroundColor Green
				Write-Host " $FileCsvComputers" -ForegroundColor Yellow
			}
			OutputBanner
		}
	}

	Function ADGroups {
	
		$Csv | ForEach-Object {
			$DC = $_."DC"
			$Domain = $_."Domain"
			$Name = $_."Name"

			$FileCsvGroups = "$CsvPath\ADGroups_$Name.csv"
			Write-Host ":: Export objects type AD Groups - Domain $Name" -ForegroundColor White -BackgroundColor DarkGreen

			$ADGroups = Get-ADGroup -Filter * -Server $DC -SearchBase $Domain -Properties *
			$ADGroups | Select-Object Name,Description,info,DistinguishedName,whenCreated,whenChanged,`
				@{Name='Member';Expression={($_.Member | % {(Get-ADObject $_).Name}) -join ";"}},`
				@{Name='MemberOf';Expression={($_.MemberOf | % {(Get-ADObject $_).Name}) -join ";"}},`
				GroupCategory,GroupScope,ObjectClass,ObjectGUID,SID | `
			Export-Csv $FileCsvGroups -NoTypeInformation -Encoding UTF8

			if ($DestinationPath.Length -ne 0) {
				Copy-Item -Path $FileCsvGroups -Destination $DestinationPath -Force
				Remove-Item -Path $FileCsvGroups -Force
                		Write-Host " [OK] Moved export file:" -ForegroundColor Green
				Write-Host " $FileCsvGroups --> $DestinationPath\ADGroups_$Name.csv" -ForegroundColor Yellow
			}
			else {
                		Write-Host " [OK] Path export file:" -ForegroundColor Green
				Write-Host " $FileCsvGroups" -ForegroundColor Yellow
            		}
			OutputBanner
		}
	}

	Function ADUsers {

		$Csv | ForEach-Object {
			$DC = $_."DC"
			$Domain = $_."Domain"
			$Name = $_."Name"

			$FileCsvUsers = "$CsvPath\ADUsers_$Name.csv"
			Write-Host ":: Export objects type AD Users - Domain $Name" -ForegroundColor White -BackgroundColor DarkGreen

			$ADUsers = Get-ADUser -Filter * -Server $DC -SearchBase $Domain -Properties *
			$ADUsers | Select-Object Name,SamAccountName,EmailAddress,DistinguishedName,Company,Enabled,Country,co,Manager,`
				Department,Description,Office,OfficePhone,LastLogonDate,whenCreated,whenChanged,DoesNotRequirePreAuth,PasswordNeverExpires,`
				@{Name="ExpirationDate";Expression={[DateTime]::FromFileTime($_."msDS-UserPasswordExpiryTimeComputed")}},`
				@{Name="pwdLastSet";Expression={[DateTime]::FromFileTime($_.pwdLastSet)}},`
				@{Name='MemberOf';Expression= {($_.MemberOf | % {(Get-ADObject $_).Name}) -join ";"}},`
				ObjectClass,ObjectGUID,SID | `
			Export-Csv $FileCsvUsers -NoTypeInformation -Encoding UTF8

			if ($DestinationPath.Length -ne 0) {
				Copy-Item -Path $FileCsvUsers -Destination $DestinationPath -Force
				Remove-Item -Path $FileCsvUsers -Force
                		Write-Host " [OK] Moved export file:" -ForegroundColor Green
				Write-Host " $FileCsvUsers --> $DestinationPath\ADUsers_$Name.csv" -ForegroundColor Yellow
			}
			else {
				Write-Host " [OK] Path export file:" -ForegroundColor Green
				Write-Host " $FileCsvUsers" -ForegroundColor Yellow
            		}                  
			OutputBanner
		}
	}

	if ($ADFull) { 
		CheckFilesCsvTemp ; ADComputers ; ADGroups ; ADUsers 
	} 
	else {
		if ($ADComputers) { CheckFilesCsvTemp ; ADComputers }
		if ($ADGroups) { CheckFilesCsvTemp ; ADGroups }
		if ($ADUsers) { CheckFilesCsvTemp ; ADUsers }
	}
}
