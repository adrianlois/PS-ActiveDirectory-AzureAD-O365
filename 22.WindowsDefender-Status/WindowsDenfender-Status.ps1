$defenderOptions = Get-MpComputerStatus

	if ([string]::IsNullOrEmpty($defenderOptions)) {
		Write-Host "Windows Defender not running on the server:" $env:computername -foregroundcolor "Yellow"
	} 
	else {
		Write-Host 'Windows Defender is active on the server:' $env:computername -foregroundcolor "Cyan" `n
		Write-Host '	Windows Defender enabled?' $defenderOptions.AntivirusEnabled
		Write-Host '	Windows Defender service enabled?' $defenderOptions.AMServiceEnabled
		Write-Host '	Windows Defender Antispware enabled?' $defenderOptions.AntispywareEnabled
		Write-Host '	Windows Defender component OnAccessProtection enabled?' $defenderOptions.OnAccessProtectionEnabled
		Write-Host '	Windows Defender component RealTimeProtection enabled?' $defenderOptions.RealTimeProtectionEnabled
	}

$defenderDisable = Read-Host 'Disable Windows Defender on the server? (Y/N)' $env:computername -foregroundcolor "Cyan"

	if ($defenderDisable -ieq 'y') {
		Uninstall-WindowsFeature -Name Windows-Defender
		Write-host "Windows Defender is disabled on the server:" $env:computername -foregroundcolor "Green"
	} 
	else {
		Write-host "Windows Defender is still running on the server:" $env:computername -foregroundcolor "Green"
	}
