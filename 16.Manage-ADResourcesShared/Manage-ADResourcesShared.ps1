[CmdletBinding()]
param (
    [Parameter(Mandatory=$True)]
    [string]$NameGroup,
    [Parameter(Mandatory=$True)]
    [string]$SharedFolder
)

$ErrorActionPreference = 'Stop'

$ConfigData = Import-LocalizedData -BaseDirectory "config\" -FileName "data.psd1"

<#
$ConfigData = @{
    PathOUPublic        = "OU=Public Groups,DC=domain,DC=local"
    PathShare           = "\\resourceShare\IT"
    NTFSOwner           = "domain\OwnerGroup"
    BackupGroup         = "domain\BackupGroup"
    PrefixNameGroup     = "grp."
}
#>

function Install-Modules {

    if ( -not (((Get-Module -ListAvailable).name -eq "NTFSSecurity") -or ((Get-Module -ListAvailable).name -eq "ActiveDirectory")) ) {

        Install-Module -Name NTFSSecurity -RequiredVersion 4.2.4 -AllowClobber -Verbose -AcceptLicense -Confirm:$false -Repository PSGallery
        Import-Module -Name ActiveDirectory
        Import-Module -Name NTFSSecurity
    }
}

function New-ADGroupShare {

    $NameGroupAD = $ConfigData.PrefixNameGroup.ToString() + $NameGroup
    $PathShare = $ConfigData.PathShare.ToString()
    $DescriptionPath = $PathShare + $SharedFolder
    $PathOUPublic = $ConfigData.PathOUPublic.ToString()
    
    <#
    $GroupCheck = Get-ADGroup -LDAPFilter "(SAMAccountName=$NameGroupAD)"
    
    if ( $GroupCheck -eq $Null ) {
        Write-Host "[*] The group already exists " -ForegroundColor White -BackgroundColor DarkGreen
    }
    #>

    $UserFile = Get-Content "config\ADUsers.txt"
        Foreach ( $UserMember in $UserFile ) {      
            New-ADGroup `
                -Name $NameGroupAD `
                -SamAccountName $NameGroupAD `
                -GroupCategory Security `
                -GroupScope Global `
                -DisplayName $NameGroupAD `
                -Path $PathOUPublic `
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
    $BackupGroup = $ConfigData.BackupGroup.ToString()

    #Set-NTFSOwner -Path $DescriptionPath -Account $NTFSOwner
    Disable-NTFSAccessInheritance -RemoveInheritedAccessRules -Path $DescriptionPath
    Add-NTFSAccess -Path "$DescriptionPath" -Account $NTFSOwner -AccessRights FullControl -AccessType Allow -AppliesTo ThisFolderSubfoldersAndFiles
    Add-NTFSAccess -Path "$DescriptionPath" -Account $BackupGroup -AccessRights FullControl -AccessType Allow -AppliesTo ThisFolderSubfoldersAndFiles
    Add-NTFSAccess -Path "$DescriptionPath" -Account $NameGroupAD -AccessRights Modify -AccessType Allow -AppliesTo ThisFolderSubfoldersAndFiles

    Write-Host "[+] The permissions assigned successfully for $NameGroupAD " -ForegroundColor White -BackgroundColor DarkGreen
}
