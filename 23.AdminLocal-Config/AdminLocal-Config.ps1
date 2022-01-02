function New-uadm {

    $adminGroup = (Get-LocalGroup -Name "Administra*s").Name | Select-Object -First 1
    $uadmUser = "uadm"
    $uadm = Get-LocalUser | Where-Object {$_.Name -eq "$useruadm"} | Select-Object Name
    $uadmPass = ConvertTo-SecureString -String "PASSWORD_ADM_LOCAL" -AsPlainText -Force

    if ( -not $uadm ) {
        New-LocalUser $uadmUser -PasswordNeverExpires -Password $uadmPass
        Add-LocalGroupMember -Group $adminGroup -Member $uadmUser
    }
}

function Disable-AdminAccount {

    $adminAccount = (Get-LocalUser -Name "Administra*r").Name | Select-Object -First 1

    if ( $adminAccount ) {
        Disable-LocalUser -Name $adminAccount
    }
}

New-uadm
Disable-AdminAccount