<#
    .DESCRIPTION
    "Get-HotFix | Sort-Object HotFixID | Format-Table –AutoSize". This only shows Windows Updates, not all Microsoft Updates for example Microsoft Application Updates, Drivers, etc.
    With this script get a list of all Microsoft Updates. Shows all Microsoft Updates, not just Windows Updates like Get-HotFix
#>

function Get-MSUpdates {

    $wu = New-Object -com "Microsoft.Update.Searcher"
    $TotalUpdates = $wu.GetTotalHistoryCount()
    $all = $wu.QueryHistory(0,$TotalUpdates)
    $OutputCollection=  @()
            
    foreach ($update in $all) {

        $string = $update.title
        $Regex = "KB\d*"
        $KB = $string | Select-String -Pattern $regex | Select-Object { $_.Matches }
        $output = New-Object -TypeName PSobject
        $output | Add-Member NoteProperty "HotFixID" -value $KB.' $_.Matches '.Value
        $output | Add-Member NoteProperty "Title" -value $string
        $OutputCollection += $output
    }

    Write-Host `n"$($OutputCollection.Count) Updates Found" -ForegroundColor Yellow
    $OutputCollection | Sort-Object HotFixID | Format-Table -AutoSize
}