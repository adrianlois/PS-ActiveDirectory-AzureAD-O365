<#
.EXAMPLE
Full export. Single destination (only the -CsvPath parameter), without parameter -DestinationPath
   C:\PS> FullExport-ADObjects -ADFull -CsvPath "C:\Users\USER\Desktop\ExportAD"

DestinationPath: Perform a full export by writing the files locally, once exported move these .csv files to a share.
   C:\PS> FullExport-ADObjects -ADFull -CsvPath "C:\Users\USER\Desktop\ExportAD" -DestinationPath "\\server\shared\"

ADUsers, ADGroups, ADComputers: Boolean parameters, specify what you want to export. ADFull (implies all parameters).
   C:\PS> FullExport-ADObjects -ADUsers -ADGroups -CsvPath "C:\Users\USER\Desktop\ExportAD" -DestinationPath "\\server\shared\"
   C:\PS> FullExport-ADObjects -ADComputers -CsvPath "C:\Users\USER\Desktop\ExportAD" -DestinationPath "\\server\shared\"
#>

# Import-Module -Name ActiveDirectory

Function FullExport-ADObjects {

	[cmdletbinding()]
	param (
		[Parameter(Mandatory=$True)]
		[string]$CsvPath,
		[string]$DestinationPath,
		[switch]$ADUsers=$False,
		[switch]$ADGroups=$False,
		[switch]$ADComputers=$False,
		[switch]$ADFull=$False
	)

$ErrorActionPreference = "Stop"
$GetDate = Get-Date -Format "dd-MM-yyyy"

# Replace domains. Add or remove row values for multiple domains. In case of a single domain set only one row and remove the rest of rows.
$Csv = @"
"DC";"Domain";"Name"
"DC01DOM1.domain.local";"DC=domain,DC=local";"Domain"
"DC01DOM2.logistic.domain.local";"DC=logistic,DC=domain,DC=local";"Logistic"
"DC01DOM3.central.domain.local";"DC=central,DC=domain,DC=local";"Central"
"@ | ConvertFrom-CSV -Delimiter ';'

	Function OutputBanner {
		Write-Host "<<< Finished OK! >>>" -ForegroundColor White -BackgroundColor DarkCyan
	}

	Function CheckCsvFilesOld {
		
		if (Test-Path -Path "$CsvPath\*" -Include *.csv) {
			Write-Host "`nCurrent .csv files in the directory: $CsvPath`n" -ForegroundColor Green
			$GetCsvFiles = (Get-ChildItem -Path "$CsvPath\*" -Include *.csv).Name ; $GetCsvFiles
			$(Write-Host "`nDo you want to delete previous export files?" -NoNewLine -ForegroundColor Red) + `
			$(Write-Host " Y/N: " -NoNewLine -ForegroundColor Cyan)
			$DeleteFilesCsv = Read-Host
			
			if ($DeleteFilesCsv -ieq 'y') {
				Remove-Item -Path $GetCsvFiles -Force
				$(Write-Host "`n[OK] Deleted .csv files in the directory: " -NoNewLine -ForegroundColor Green) + `
				$(Write-Host "$CsvPath`n" -ForegroundColor Yellow)
			}
		}
	}

	Function ADUsers {

		$Csv | ForEach-Object {
			$DC = $_."DC"
			$Domain = $_."Domain"
			$Name = $_."Name"

			$CsvFileUsers = "$CsvPath\ADUsers_$Name`_$GetDate.csv"
			Write-Host "`n:: Export objects type AD Users - Domain $Name" -ForegroundColor White -BackgroundColor DarkGreen

			$ADUsers = Get-ADUser -Filter * -Server $DC -SearchBase $Domain -Properties *
			$ADUsers | Select-Object Name,SamAccountName,EmailAddress,DistinguishedName,Company,Enabled,Country,co,Manager,`
				Department,Description,Office,OfficePhone,LastLogonDate,whenCreated,whenChanged,DoesNotRequirePreAuth,PasswordNeverExpires,`
				@{Name="ExpirationDate";Expression={[DateTime]::FromFileTime($_."msDS-UserPasswordExpiryTimeComputed")}},`
				@{Name="pwdLastSet";Expression={[DateTime]::FromFileTime($_.pwdLastSet)}},`
				@{Name='MemberOf';Expression= {($_.MemberOf | % {(Get-ADObject $_).Name}) -join ";"}},`
				ObjectClass,ObjectGUID,SID | `
			Export-Csv $CsvFileUsers -NoTypeInformation -Encoding UTF8 -Force

			if ($DestinationPath.Length -ne 0) {
				Copy-Item -Path $CsvFileUsers -Destination $DestinationPath -Force
				Remove-Item -Path $CsvFileUsers -Force
				$(Write-Host " [OK] Moved export file:" -NoNewLine -ForegroundColor Green) + `
				$(Write-Host " $CsvFileUsers --> $DestinationPath\ADUsers_$Name`_$GetDate.csv" -ForegroundColor Yellow)
			}
			else {
				$(Write-Host " [OK] Path export file:" -NoNewLine -ForegroundColor Green) + `
				$(Write-Host " $CsvFileUsers" -ForegroundColor Yellow)
			}                  
			OutputBanner
		}
	}

	Function ADGroups {
	
		$Csv | ForEach-Object {
			$DC = $_."DC"
			$Domain = $_."Domain"
			$Name = $_."Name"

			$CsvFileGroups = "$CsvPath\ADGroups_$Name`_$GetDate.csv"
			Write-Host "`n:: Export objects type AD Groups - Domain $Name" -ForegroundColor White -BackgroundColor DarkGreen

			$ADGroups = Get-ADGroup -Filter * -Server $DC -SearchBase $Domain -Properties *
			$ADGroups | Select-Object Name,Description,info,DistinguishedName,whenCreated,whenChanged,`
				@{Name='Member';Expression={($_.Member | % {(Get-ADObject $_).Name}) -join ";"}},`
				@{Name='MemberOf';Expression={($_.MemberOf | % {(Get-ADObject $_).Name}) -join ";"}},`
				GroupCategory,GroupScope,ObjectClass,ObjectGUID,SID | `
			Export-Csv $CsvFileGroups -NoTypeInformation -Encoding UTF8 -Force

			if ($DestinationPath.Length -ne 0) {
				Copy-Item -Path $CsvFileGroups -Destination $DestinationPath -Force
				Remove-Item -Path $CsvFileGroups -Force
				$(Write-Host " [OK] Moved export file:" -NoNewLine -ForegroundColor Green) + `
				$(Write-Host " $CsvFileGroups --> $DestinationPath\ADGroups_$Name`_$GetDate.csv" -ForegroundColor Yellow)
			}
			else {
				$(Write-Host " [OK] Path export file:" -NoNewLine -ForegroundColor Green) + `
				$(Write-Host " $CsvFileGroups" -ForegroundColor Yellow)
			}
			OutputBanner
		}
	}

	Function ADComputers {
	
		$Csv | ForEach-Object {
			$DC = $_."DC"
			$Domain = $_."Domain"
			$Name = $_."Name"

			$CsvFileComputers = "$CsvPath\ADComputers_$Name`_$GetDate.csv"
			Write-Host "`n:: Export objects type AD Computers - Domain $Name" -ForegroundColor White -BackgroundColor DarkGreen
            
			$ADComputers = Get-ADComputer -Filter * -Server $DC -SearchBase $Domain -Properties `
				Name,DistinguishedName,DNSHostName,Name,IPv4Address,Enabled,LastLogonDate,whenCreated,`
				OperatingSystem,OperatingSystemVersion,Location,ObjectClass,ObjectGUID,SID
			$ADComputers | Export-Csv $CsvFileComputers -NoTypeInformation -Encoding UTF8 -Force

			if ($DestinationPath.Length -ne 0) {
				Copy-Item -Path $CsvFileComputers -Destination $DestinationPath -Force
				Remove-Item -Path $CsvFileComputers -Force
				$(Write-Host " [OK] Moved export file:" -NoNewLine -ForegroundColor Green) + `
				$(Write-Host " $CsvFileComputers --> $DestinationPath\ADComputers_$Name`_$GetDate.csv" -ForegroundColor Yellow)
			}
			else {
				$(Write-Host " [OK] Path export file:" -NoNewLine -ForegroundColor Green) + `
				$(Write-Host " $CsvFileComputers" -ForegroundColor Yellow)
			}
			OutputBanner
		}
	}

	if ($ADFull) { 
		CheckCsvFilesOld ; ADUsers ; ADGroups ; ADComputers
	} 
	else {
		if ($ADUsers) { CheckCsvFilesOld ; ADUsers }
		if ($ADGroups) { CheckCsvFilesOld ; ADGroups }
		if ($ADComputers) { CheckCsvFilesOld ; ADComputers }
	}
}
