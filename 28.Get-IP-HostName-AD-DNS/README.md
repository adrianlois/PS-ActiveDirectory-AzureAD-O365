# Get IP HostName AD DNS

Two ways to get the IP addresses from a list of DNS hostnames of a domain by importing a csv file.

- **Get-IP-HostName-AD.ps1**: Do it with the *Get-ADComputer* cmdlet to get the IP address from the Active Directory computer object attributes. Use the ActiveDirectory module.

- **Get-IP-HostName-DNS.ps1**: Do this with the *Get-DnsServerResourceRecord* cmdlet to get the IP address via the type A record associated with the DNS hostname domain. Use the DnsServer module.