# Get ADUsers Last WhenCreated

With this script get a list of all Microsoft Updates. Shows all Microsoft Updates, not just Windows Updates like Get-HotFix

### Use

We load the function and invoke
```powershell
Get-MSUpdates
```

### Remark

This only shows Windows Updates, not all Microsoft Updates for example Microsoft Application Updates, Drivers, etc.
```powershell
Get-HotFix | Sort-Object HotFixID | Format-Table –AutoSize
```
