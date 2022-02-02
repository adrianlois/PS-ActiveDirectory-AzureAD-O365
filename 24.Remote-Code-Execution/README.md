# Remote Code Execution Options

There are several different ways to execute commands remotely on a Domain Controller, assuming they are executed with the appropriate rights. The most reliable remote execution methods involve either PowerShell (leverages WinRM) or WMI.

- **WMI**
```powershell
wmic /node:COMPUTER/user:DOMAIN\USER /password:PASSWORD process call create “COMMAND“
```

- **PowerShell (WMI)**
```powershell
Invoke-WMIMethod -Class Win32_Process -Name Create -ArgumentList $COMMAND -ComputerName $COMPUTER -Credential $CRED
```

- **WinRM**
```powershell
winrs -r:COMPUTER COMMAND
```

- **PowerShell Remoting**
```powershell
Invoke-Command -computername $COMPUTER -command {$COMMAND}
New-PSSession -Name PSCOMPUTER -ComputerName $COMPUTER; Enter-PSSession -Name PSCOMPUTER
```