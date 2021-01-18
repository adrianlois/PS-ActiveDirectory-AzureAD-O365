[CmdletBinding()]
param (
    [Parameter(Mandatory=$True)]
    [string]$NameGroupAD,
    [Parameter(Mandatory=$True)]
    [string]$SharedFolder
)

$ErrorActionPreference = 'Stop'

$ConfigData = Import-LocalizedData -BaseDirectory "config\" -FileName "data.psd1"

function Install-Modules {

    if (-not (((Get-Module -ListAvailable).name -eq "NTFSSecurity") -or ((Get-Module -ListAvailable).name -eq "ActiveDirectory"))) {

        Install-Module -Name NTFSSecurity -RequiredVersion 4.2.4 -AllowClobber -Verbose -AcceptLicense -Confirm:$false -Repository PSGallery
        Import-Module -Name ActiveDirectory
        Import-Module -Name NTFSSecurity
    }
}

function New-ADGroupShare {

    $NameGroupAD = $PrefixNameGroup + $NameGroup
    $PathShare = $ConfigData.PathShare.ToString()
    $DescriptionPath = $PathShare + $SharedFolder
    $PathOUIntercambio = $ConfigData.PathOUIntercambio.ToString()
    
    <#
    $GroupCheck = Get-ADGroup -LDAPFilter "(SAMAccountName=$NameGroupAD)"
    
    if ( $GroupCheck -eq $Null ) {
        Write-Host "[*] The group already exists " -ForegroundColor White -BackgroundColor DarkGreen
    }
    #>

    $UserFile = Get-Content "UserFile.txt"
        Foreach ( $UserMember in $UserFile ) {      
            New-ADGroup `
                -Name $NameGroupAD `
                -SamAccountName $NameGroupAD `
                -GroupCategory Security `
                -GroupScope Global `
                -DisplayName $NameGroupAD `
                -Path $PathOUIntercambio `
                -Description "$DescriptionPath"

            Add-ADGroupMember `
                -Identity $NameGroupAD `
                -Members $UserMember
        }

    Write-Host "[+] The group was created successfully " -ForegroundColor White -BackgroundColor DarkGreen
}

function New-Directory {

    $PathCheck = Test-Path -Path $DescriptionPath

    if ($PathCheck -eq $True) {
        Write-Host "[*] The directory already exists " -ForegroundColor White -BackgroundColor Red
    }

    New-Item -ItemType Directory -Path "$DescriptionPath"
    Write-Host "[+] The directory was created successfully " -ForegroundColor White -BackgroundColor DarkGreen
}

function Set-NTFSAcl {
    
    $NTFSOwner = $ConfigData.NTFSOwner.ToString()
    $BackupAgent = $ConfigData.BackupAgent.ToString()

    #Set-NTFSOwner -Path $DescriptionPath -Account $NTFSOwner
    Disable-NTFSAccessInheritance -RemoveInheritedAccessRules -Path $DescriptionPath
    Add-NTFSAccess -Path "$DescriptionPath" -Account $NTFSOwner -AccessRights FullControl -AccessType Allow -AppliesTo ThisFolderSubfoldersAndFiles
    Add-NTFSAccess -Path "$DescriptionPath" -Account $BackupAgent -AccessRights FullControl -AccessType Allow -AppliesTo ThisFolderSubfoldersAndFiles
    Add-NTFSAccess -Path "$DescriptionPath" -Account $NameGroup -AccessRights Modify -AccessType Allow -AppliesTo ThisFolderSubfoldersAndFiles

    Write-Host "[+] The permissions assigned successfully for $NameGroup " -ForegroundColor White -BackgroundColor DarkGreen
}
