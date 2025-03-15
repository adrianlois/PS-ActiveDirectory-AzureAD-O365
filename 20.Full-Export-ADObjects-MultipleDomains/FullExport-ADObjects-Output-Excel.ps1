Function ImportModules {
	Import-Module -Name ActiveDirectory
	Import-Module -Name ImportExcel
}

Function OutputBanner {
	Write-Host "<<<<< Finished OK! >>>>>" -ForegroundColor White -BackgroundColor DarkCyan `n
}

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
"@ | ConvertFrom-CSV -Delimiter ';'

	Function CheckFilesCsvTemp {
		$fileCsvTemp = "$CsvPath\*"
		if (Test-Path $fileCsvTemp -PathType leaf) {
			Remove-Item -Path $fileCsvTemp -Force
		}
	}

	Function ADComputers {
	
		$Csv | ForEach-Object {
			$DC = $_."DC"
			$Domain = $_."Domain"
			$Name = $_."Name"

			$FileCsvComputers = "$CsvPath\ADComputers_$Name.csv"
			Write-Host ":: Export objects type AD Computers - Domain $Name" -ForegroundColor White -BackgroundColor DarkGreen
            
			$ADComputers = Get-ADComputer -Filter * -Server $DC -SearchBase $Domain -Properties `
				Name,DistinguishedName,DNSHostName,Name,IPv4Address,Enabled,LastLogonDate,whenCreated,`
				OperatingSystem,OperatingSystemVersion,ObjectClass,ObjectGUID,SID
			$ADComputers | Export-Csv $FileCsvComputers -NoTypeInformation -Encoding UTF8

			if ($DestinationPath.Length -ne 0) {
				Copy-Item -Path $FileCsvComputers -Destination $DestinationPath -Force
				Remove-Item -Path $FileCsvComputers -Force
				$(Write-Host " [OK] Moved export file:" -NoNewLine -ForegroundColor Green) + `
				$(Write-Host " $FileCsvComputers --> $DestinationPath\ADComputers_$Name`_$GetDate.csv" -ForegroundColor Yellow)
			}
			else {
				$(Write-Host " [OK] Path export file:" -NoNewLine -ForegroundColor Green) + `
				$(Write-Host " $FileCsvComputers" -ForegroundColor Yellow)
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
				$(Write-Host " [OK] Moved export file:" -NoNewLine -ForegroundColor Green) + `
				$(Write-Host " $FileCsvGroups --> $DestinationPath\ADGroups_$Name`_$GetDate.csv" -ForegroundColor Yellow)
			}
			else {
				$(Write-Host " [OK] Path export file:" -NoNewLine -ForegroundColor Green) + `
				$(Write-Host " $FileCsvGroups" -ForegroundColor Yellow)
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
				$(Write-Host " [OK] Moved export file:" -NoNewLine -ForegroundColor Green) + `
				$(Write-Host " $FileCsvUsers --> $DestinationPath\ADUsers_$Name`_$GetDate.csv" -ForegroundColor Yellow)
			}
			else {
				$(Write-Host " [OK] Path export file:" -NoNewLine -ForegroundColor Green) + `
				$(Write-Host " $FileCsvUsers" -ForegroundColor Yellow)
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

Function Get-Inactivity-ADUsersLastLogon {

	[CmdletBinding()]
	param (
		[Parameter(Mandatory)]
		[string]$CsvPath
	)

	$Csv | ForEach-Object {
		$Name = $_."Name"
		$CsvFile = "ADUsers_LastLogon90Days_$Name.csv"

		Write-Host ":: Export inactivity last logon 90 days AD Users - Domain $Name" -ForegroundColor White -BackgroundColor DarkGreen
		$(Write-Host " [OK] Path export file:" -NoNewLine -ForegroundColor Green) + `
		$(Write-Host " $CsvPath\$CsvFile" -ForegroundColor Yellow)

		[int]$Days = 90
		$Time = (Get-Date).AddDays(-$Days)

		Get-ADUser -Filter * -Properties * | `
		Select-Object Name,EmailAddress,DistinguishedName,SamAccountName,PasswordNeverExpires,Enabled,whenCreated,LastLogonDate | `
		Where-Object { ($_.LastLogonDate -lt $Time) -and ($_.Enabled -like "True") } | `
		Sort-Object -Property LastLogonDate | `
		Export-Csv -Path "$CsvPath\$CsvFile" -NoTypeInformation -Encoding UTF8
		
		OutputBanner
	}
}

Function CsvToExcel {
	param (
		[Parameter(Mandatory=$True)]
		[string]$CsvPath
	)

	$Date = Get-Date -Format "MM-yyyy"
	$XlsxFile = "Export_AD_" + $Date + ".xlsx"
	$CsvFiles = (Get-ChildItem -Path $CsvPath -Filter "*.csv").Name

	ForEach ($CsvFile in $CsvFiles) {
	
		$WorkSheetname = $CsvFile.Substring(0,$CsvFile.Length -4)

		Import-Csv -Path "$CsvPath\$CsvFile" | Export-Excel -Path "$CsvPath\$XlsxFile" -WorkSheetname $WorkSheetname `
		-NoNumberConversion IPv4Address	-AutoSize -BoldTopRow -AutoFilter -FreezeTopRow -ConditionalText $(
			New-ConditionalText True -BackgroundColor LightGreen -ConditionalTextColor DarkGreen
			New-ConditionalText False -BackgroundColor Yellow -ConditionalTextColor Red
		)
	}
}

Function Move-ExcelFile {
	param (
		[Parameter(Mandatory)]
		[string]$Path,
		[Parameter(Mandatory)]
		[string]$Destination
	)
	
	$Date = Get-Date -Format "MM-yyyy"
	$XlsxFile = "Export_AD_" + $Date + ".xlsx"
	Copy-Item -Path "$Path\$XlsxFile" -Destination "$Destination" -Force
	#Remove-Item -Path "$Path\*" -Force
}

# Paths Variables & Invoke functions
$PathWork = "C:\Tasks\Export_AD\Temp"
$PathDestinationShare = "\\NAS\Export_AD\Domain\"

ImportModules
FullExport-ADObjects -ADFull -CsvPath "$PathWork"
Get-Inactivity-ADUsersLastLogon -CsvPath "$PathWork"
CsvToExcel -CsvPath "$PathWork"
Move-ExcelFile -Path "$PathWork" -Destination "$PathDestinationShare"