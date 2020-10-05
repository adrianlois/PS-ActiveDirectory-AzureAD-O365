function Migrate-UserProfile {

<#
    .EXAMPLE
    C:\PS> Migrate-UserProfile -PCSrc "PC1" -PCDst "PC2" -User "adrian"
#>

    param (
        [parameter(Mandatory = $true)]
        [String]
        $PCSrc,
        [parameter(Mandatory = $true)]
        [String]
        $PCDst,
        [parameter(Mandatory = $true)]
        [String]
        $User
    )

    $src = "\\$PCSrc\c$\Users\$User\"
    $dst = "\\$PCDst\c$\Users\$User\"
    $log = $dst+"CopyUserProfile_$User.log"

    $paths = @(
        "Desktop",
        "Downloads",
        "Pictures",
        "Favorites",
        "AppData\Local\MicrosoftEdge",
        "AppData\Local\Microsoft\Internet Explorer",
        "AppData\Local\Google\Chrome\User Data",
        "AppData\Local\Mozilla\Firefox\Profiles"
    )

    foreach ( $path in $paths ) {

        $srcPath = $src+$path
        $dstPath = $dst+$path

        if ( (Test-Path -Path $srcPath) -eq $True ) {

            Write-Host "[+] Copying ... $path of $User from $PCSrc -> $PCDst " -ForegroundColor White -BackgroundColor DarkGreen
            ROBOCOPY "$srcPath" "$dstPath" /MIR /Z /W:5 /LOG+:$log
        } 
	else {
            Write-Host "[!] The $path directory doesn't exist for the user $User in $PCSrc " -ForegroundColor White -BackgroundColor DarkRed
        }
    }
    
    Start-Process $log
    Start-Sleep 2
    Remove-Item -Path $log -Force
}
