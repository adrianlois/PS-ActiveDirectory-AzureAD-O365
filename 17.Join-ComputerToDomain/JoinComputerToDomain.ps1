function Rename-Computer {
    param (
    	[Parameter(Mandatory=$true)]
	[string]$ComputerName
    )

    process {
        try {
	    $computer = Get-WmiObject -Class Win32_ComputerSystem
 	    $result = $computer.Rename($name)

            switch($result.ReturnValue) {       
                0 { Write-Host "Computer name has been changed." }
                5 { 
		    Write-Error "You need administrative privileges." 
		    exit 
		}
                default {
		    Write-Host "Error: Return value " $result.ReturnValue
	            exit
                }
            }
        }
	catch {
	    Write-Host "An error has occurred in the name change operation: " $Error
        }
    }
}

function Join-ComputerToDomain {
    param ( 
	[Parameter(Mandatory=$true)]
	[string]$Domain 
     )

    process {
	try {
            $domainCredential = $Host.UI.PromptForCredential("Enter your domain credentials", "Enter your credentials to join the computer to the domain:", "", "NetBiosUserName")
            Add-Computer -DomainName $domain -Credential $domainCredential
        }
        catch {
            Write-Error "An error has occurred in the operation of joining the computer to the domain. " $Error
	}
    }
}

Rename-Computer
Join-ComputerToDomain
