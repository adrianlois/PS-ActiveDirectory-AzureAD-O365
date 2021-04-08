Import-Module ActiveDirectory

$importFileCSV = "users.csv"

Import-Csv $importFileCSV | Foreach-Object {

    $samAccountName = $_."samAccountName"
    $samAccountExist = Get-ADUser -Filter 'SamAccountName -Like $samAccountName'

        if ( $samAccountExist ) {
            Set-ADUser -Identity $samAccountName -Replace @{Attribute1LDAPDisplayName="Value1";Attribute2LDAPDisplayName="Value2";Attribute3LDAPDisplayName=$True}
            Write-Host "`n[+] The attributes of user $samAccountName have been modified in AD " -ForegroundColor White -BackgroundColor DarkGreen
        }
        else {
            Write-Host "`n[-] The user $samAccountName not exists in AD " -ForegroundColor Red -BackgroundColor Yellow
        }
}