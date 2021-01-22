function Check-AdminPrivileges {

    # Check for administrative rights
    Write-Host "Checking privileges..." -ForegroundColor Red -BackgroundColor Yellow
    
    if ( -NOT ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator") ) {
    	Write-Warning -Message " [!] The script requires privilege elevation, execute as Admin mode"
	break
    } 
    else {
	Write-Host " [+] This script runs in Admin mode"  -ForegroundColor White -BackgroundColor DarkGreen 
    }
}

function Set-NewUserPasswordEncrypt {

    $path = "C:\Passwords" #Set you path
    $keyFile = New-Object Byte[] 32
    [Security.Cryptography.RNGCryptoServiceProvider]::Create().GetBytes($keyFile)
    $keyFile | Out-File "$path\KeyFilePasswd.key"

    Read-Host -AsSecureString "Set a Password" | ConvertFrom-SecureString -key (Get-Content "$path\KeyFilePasswd.key") | Set-Content "$path\EncryptPasswd"

    $password = Get-Content "$path\EncryptPasswd" | ConvertTo-SecureString -Key (Get-Content "$path\KeyFilePasswd.key")
    return $password
}

function New-AdmUser {

    $passwd = Set-NewUserPasswordEncrypt
    $adminGroup = (Get-LocalGroup -Name "Administra*s").Name | Select-Object -First 1
    $userGroup = (Get-LocalGroup -Name "Us*s").Name | Select-Object -First 1
    $admUser = "admuser"
    $admUserCheck = Get-LocalUser | Where-Object {$_.Name -eq "$admUser"} | Select-Object Name
    $admUserPass = ConvertTo-SecureString -String "$passwd" -AsPlainText -Force

    if ( -not $admUserCheck ) {
        New-LocalUser -Name $admUser -PasswordNeverExpires:$True -Password $admUserPass
        Add-LocalGroupMember -Group $adminGroup -Member $admUser
        Remove-LocalGroupMember -Group $userGroup -Member $admUser

        $sid = (Get-LocalUser -Name "user").sid.value
        $pathReg = "HKLM:\SOFTWARE\LogMeIn\V5\Permissions\$sid"
        
        if ( (Test-Path -Path $pathReg) -eq $False ) {
            New-Item -Path "HKLM:\SOFTWARE\LogMeIn\V5\Permissions"
            New-ItemProperty -Path "HKLM:\SOFTWARE\LogMeIn\V5\Permissions" -Name AllowAdmin -PropertyType DWORD -Value "1" -Force
            
            New-Item -Path $pathReg
            New-ItemProperty -Path $pathReg -Name AccessMask -PropertyType QWORD -Value "343604723713" -Force
            New-ItemProperty -Path $pathReg -Name FilterProfile -PropertyType String -Value "" -Force
            New-ItemProperty -Path $pathReg -Name ForceUI -PropertyType DWORD -Value "0" -Force
            New-ItemProperty -Path $pathReg -Name SSHStreamShell -PropertyType DWORD -Value "0" -Force
        }
        <#
        -PropertyType
        String (REG_SZ)
        Binary (REG_BINARY)
        Dword (REG_DWORD)
        Qword (REG_QWORD)
        MultiString (REG_MULTI_SZ)
        ExpandString (REG_EXPAND_SZ)
        #>
    }
}

function Remove-AdmUserAdminGroup {

    $admUser = Get-LocalUser -Name "admuser" | Select-Object Name
    $userGroup = (Get-LocalGroup -Name "Us*s").Name | Select-Object -First 1  
    $adminGroup = (Get-LocalGroup -Name "Administra*s").Name | Select-Object -First 1

    if ( $admUser ) {
        Add-LocalGroupMember -Group $userGroup -Member $admUser
        Remove-LocalGroupMember -Group $adminGroup -Member $admUser
    }
}

function Remove-AdmUser {

    $admUser = (Get-LocalUser | Where-Object {$_.Name -eq "admuser"}).Name

    if ( $admUser ) {
        Remove-LocalUser -Name $admUser
    }
}

function Disable-AdminDefaultAccount {

    $adminAccount = (Get-LocalUser -Name "Administra*r").Name | Select-Object -First 1

    if ( $adminAccount ) {
        Disable-LocalUser -Name $adminAccount
    }
}

#Check-AdminPrivileges
#Set-NewUserPasswordEncrypt
#New-AdmUser
#Remove-AdmUserAdminGroup
#Remove-AdmUser
#Disable-AdminDefaultAccount
