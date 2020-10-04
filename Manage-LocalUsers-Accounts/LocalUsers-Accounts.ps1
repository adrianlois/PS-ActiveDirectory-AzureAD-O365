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
    $admUser = "admuser"
    $admUserCheck = Get-LocalUser | Where-Object {$_.Name -eq "$admUser"} | Select-Object Name
    $admUserPass = ConvertTo-SecureString -String "$passwd" -AsPlainText -Force

    if ( -not $admUserCheck ) {
        New-LocalUser -Name $admUser -PasswordNeverExpires:$True -Password $admUserPass
        Add-LocalGroupMember -Group $adminGroup -Member $admUser
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

#Set-NewUserPasswordEncrypt
#New-AdmUser
#Remove-AdmUserAdminGroup
#Remove-AdmUser
#Disable-AdminDefaultAccount