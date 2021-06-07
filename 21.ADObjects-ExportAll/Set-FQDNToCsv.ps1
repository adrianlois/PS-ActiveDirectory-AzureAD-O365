<#
    Use this script as an example to add a new column to an existing csv file.
#>
#Import-Module ActiveDirectory

Function Set-FQDNToCsv {

    param (
        [Parameter(Mandatory=$True)]
        [string]$ADObjectsPath,
        [Parameter(Mandatory=$True)]
        [string]$ADObjectsCsv
    )

    $ADObjectsPathCsv = $ADObjectsPath + $ADObjectsCsv
    $ADObjectsTemp = $ADObjectsPath + "temp_" + $ADObjectsCsv

    if (Test-Path $ADObjectsTemp -PathType leaf)	{
	    Remove-Item -Path $ADObjectsTemp -Force
    }

    Rename-Item -Path $ADObjectsPathCsv -NewName $ADObjectsTemp

	# Add new FQDN field (hostname+domain) to ADObjects csv file
    Import-Csv -Path $ADObjectsTemp | `
    Select-Object *, @{Name='FQDN';Expression={($_.Hostname + "." + $_.Domain + "." + "domain.local").ToLower()}} | `
    Export-Csv "$ADObjectsPathCsv" -NoTypeInformation -Encoding UTF8

    Remove-Item -Path $ADObjectsTemp -Force
}

Set-FQDNToCsv -ADObjectsPath "\\shared\export\" -ADObjectsCsv "AD_Objects.csv"
