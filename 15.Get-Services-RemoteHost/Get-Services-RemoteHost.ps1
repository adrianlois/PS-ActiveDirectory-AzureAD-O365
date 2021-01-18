$ServciesSrvAll = "%userprofile%\Desktop\GetServices-Srv-All.txt"
$ServciesSrvAdm = "%userprofile%\Desktop\GetServices-Srv-Adm.txt"
$LocalUserSrvAll = "%userprofile%\Desktop\GetLocalUsers-Srv-All.txt"
$PathFileCSV = "%userprofile%\Desktop\srv.csv"

Remove-Item -Path $ServciesSrvAll,$ServciesSrvAdm,$LocalUserSrvAll,$PathFileCSV -Force
Write-Output "hostname" | Out-File $PathFileCSV
# "SRV*" is match criteria the file CSV
(Get-ADComputer -Filter 'Name -like "SRV*"').Name | Out-File -Append $PathFileCSV

Import-Csv -Path $PathFileCSV | Foreach-Object {

    $hostname = $_."hostname"

    Write-Output "---------- $hostname : All services ----------" | Out-File -Append $ServciesSrvAll
    Get-WmiObject win32_service -ComputerName $hostname | Format-Table startname, state, startmode, name | Out-File -Append $ServciesSrvAll
    Write-Output "***********************************" | Out-File -Append $ServciesSrvAll

    Write-Output "---------- $hostname : User Administrator Services ----------" | Out-File -Append $ServciesSrvAdm  
    Get-WmiObject win32_service -ComputerName $hostname | Where-Object {$_.startname -Like "*Administr*"} | Format-Table startname, state, startmode, name | Out-File -Append $ServciesSrvAdm 
    Write-Output "***********************************" | Out-File -Append $ServciesSrvAdm

    Write-Output "---------- $hostname : Local Users ----------" | Out-File -Append $LocalUserSrvAll
    Invoke-Command -ComputerName $hostname -ScriptBlock { Get-LocalUser } | Format-Table | Out-File -Append $LocalUserSrvAll
    Write-Output "***********************************" | Out-File -Append $LocalUserSrvAll
}