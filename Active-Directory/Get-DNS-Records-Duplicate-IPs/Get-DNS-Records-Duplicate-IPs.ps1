# Import the Active Directory Module
Import-Module ActiveDirectory

# Define an empty array to store computers with duplicate IP address registrations in DNS
$duplicate_comp = @()

# Get all computers in the current Active Directory domain along with the IPv4 address
# The IPv4 address is not a property on the computer account so a DNS lookup is performed
# The list of computers is sorted based on IPv4 address and assigned to the variable $comp
$comp = get-adcomputer -filter * -properties ipv4address | sort-object -property ipv4address

# For each computer object returned, assign just a sorted list of all
# of the IPv4 addresses for each computer to $sorted_ipv4
$sorted_ipv4 = $comp | foreach {$_.ipv4address} | sort-object

# For each computer object returned, assign just a sorted, unique list
# of all of the IPv4 addresses for each computer to $unique_ipv4
$unique_ipv4 = $comp | foreach {$_.ipv4address} | sort-object | get-unique

# compare $unique_ipv4 to $sorted_ipv4 and assign just the additional
# IPv4 addresses in $sorted_ipv4 to $duplicate_ipv4
$duplicate_ipv4 = Compare-object -referenceobject $unique_ipv4 -differenceobject $sorted_ipv4 | foreach {$_.inputobject}

# For each instance in $duplicate_ipv4 and for each instance
# in $comp, compare $duplicate_ipv4 to $comp If they are equal, assign
# the computer object to array $duplicate_comp
foreach ($duplicate_inst in $duplicate_ipv4)
{
    foreach ($comp_inst in $comp)
    {
        if (!($duplicate_inst.compareto($comp_inst.ipv4address)))
        {
            $duplicate_comp = $duplicate_comp + $comp_inst
        }
    }
}

# Pipe all of the duplicate computers to a formatted table
$duplicate_comp | ft name,ipv4address -a

