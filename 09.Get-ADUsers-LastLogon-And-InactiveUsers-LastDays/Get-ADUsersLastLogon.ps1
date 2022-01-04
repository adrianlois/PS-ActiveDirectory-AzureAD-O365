Import-Module ActiveDirectory
Set-ExecutionPolicy -Scope CurrentUser -ExecutionPolicy Bypass -Force

function Get-ADUsersLastLogon {
  $dcs = Get-ADDomainController -Filter {Name -like "*"}
  $users = Get-ADUser -Filter *
  $time = 0
  $exportFilePath = "%USERPROFILE%\Desktop\ADUsersLastLogon.csv"
  $columns = "Name,Username,Enabled,DateTime,DistinguishedName"
  
  Out-File -FilePath $exportFilePath -Force -InputObject $columns

  foreach($user in $users) {
    foreach($dc in $dcs) {
      $hostname = $dc.HostName
      $currentUser = Get-ADUser $user.SamAccountName | Get-ADObject -Server $hostname -Properties LastLogon

      if($currentUser.LastLogon -gt $time) {
        $time = $currentUser.LastLogon
      }
    }

    $dt = [DateTime]::FromFileTime($time)
    $row = $user.Name+","+$user.SamAccountName+","+$user.Enabled+","+$dt+","+$user.DistinguishedName
    Out-File -FilePath $exportFilePath -Append -NoClobber -InputObject $row
    $time = 0
  }
}

Get-ADUsersLastLogon