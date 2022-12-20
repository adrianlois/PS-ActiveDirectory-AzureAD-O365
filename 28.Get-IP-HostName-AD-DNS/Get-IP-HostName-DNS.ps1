# https://learn.microsoft.com/en-us/powershell/module/dnsserver/?view=windowsserver2022-ps
# Get-Module DNSServer –ListAvailable
# Get-Module DNSServer
# Import-Module DnsServer

$FileImportCSV = "C:\Scripts\CSV\DNSHostName.csv"

Import-Csv $FileImportCSV | Foreach-Object {

    $Domain = "domain.local"
    $PDCHostName = "DC01"   
    $DNSHostName = $_."DNSHostName"

    Get-DnsServerResourceRecord -ComputerName $PDCHostName -ZoneName $Domain -RRType A | Where-Object HostName -like "$DNSHostName" | Format-List
}