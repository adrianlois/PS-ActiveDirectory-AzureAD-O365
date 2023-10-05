Function Move-ItemExtension-RecursivePath {
<#
    .PARAMETER SrcPathFiles
    Indicate the parent root path of the source files to search in subdirectories.
    .PARAMETER ExtFiles
    Indicate the extension of the source files.
    .PARAMETER DestinationFiles
    Indicate the destination of the files to move.
    .EXAMPLE
    C:\PS> Move-Item-RecursivePath -SrcPathFiles "D:\Reports\Files" -ExtFiles "csv" -DestinationFiles "C:\CSVs"
#>
    param (
        [parameter(Mandatory = $true)]
        [String]$SrcPathFiles,
        [parameter(Mandatory = $true)]
        [String]$ExtFiles,
        [parameter(Mandatory = $true)]
        [String]$DestinationFiles
    )

    $Files = (Get-ChildItem -Path $SrcPathFiles -Recurse | Where-Object {$_.Extension -eq ".$ExtFiles"}).Fullname

    ForEach-Object {
        Move-Item -Path $Files -Destination $DestinationFiles -Force
    }

    $DeleteAll = Read-Host "[?] Delete all subdirectories of"`"$SrcPathFiles"`"? (y/n)"
    
    if ( $DeleteAll -eq "y") {
        $Exclude = Read-Host "[?] Exclude a file or directory? (indicate string/n)"
	
	if ( $Exclude -ne "n" ) {
		Get-ChildItem -Path "$SrcPathFiles" -Exclude "$Exclude" | Remove-Item -Recurse -Force
        Break
    }
    Remove-Item -Path "$SrcPathFiles\*" -Recurse -Force
    }
    Get-ChildItem -Path "$DestinationFiles"
}

# another way: execution in a single line
# (Get-ChildItem -Path $SrcPathFiles -Recurse | Where-Object {$_.Extension -eq ".$ExtFiles"}).Fullname | Move-Item -Destination $DestinationFiles ; Get-ChildItem -Path $SrcPathFiles -Exclude $Exclude | Remove-Item -Recurse -Force
