function MigrateUserProfile {

    # Get form variables
    $PCsrc = $BoxPathPCSrc.Text
    $PCDst = $BoxPathPCDst.Text
    $User = $BoxUser.Text

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

function Migrate-UserProfile-Form {

    # Form creation
    [void][System.reflection.Assembly]::LoadWithPartialName("System.Windows.Forms")
    [void][System.Reflection.Assembly]::LoadWithPartialName("System.Drawing")
    $font = New-Object System.Drawing.Font("Arial",11,[System.Drawing.FontStyle]::Bold)
    $form = New-Object System.Windows.Forms.Form
    $form.Size = New-Object System.Drawing.Size(290,305)
    $form.Text = "Migrate User Profile"

    # Labels and buttons
    $LabelPathPCSrc = New-Object System.Windows.Forms.Label
    $LabelPathPCSrc.Location = New-Object System.Drawing.Size(37,20) 
    $LabelPathPCSrc.Size = New-Object System.Drawing.Size(200,20)
    $LabelPathPCSrc.Font = $font
    $LabelPathPCSrc.Text = "Hostname PC Source:"
    $form.Controls.Add($LabelPathPCSrc)
    
    $BoxPathPCSrc = New-Object System.Windows.Forms.Textbox
    $BoxPathPCSrc.Location = New-Object System.Drawing.point(37,40)
    $BoxPathPCSrc.Size = New-Object System.Drawing.Size(200,20)
    $BoxPathPCSrc.Font = $font
    $BoxPathPCSrc.Text = ""
    $form.Controls.Add($BoxPathPCSrc)

    $LabelPathPCDst = New-Object System.Windows.Forms.Label
    $LabelPathPCDst.Location = New-Object System.Drawing.Size(37,80) 
    $LabelPathPCDst.Size = New-Object System.Drawing.Size(200,20)
    $LabelPathPCDst.Font = $font
    $LabelPathPCDst.Text = "Hostname PC Destination:"
    $form.Controls.Add($LabelPathPCDst)
    
    $BoxPathPCDst = New-Object System.Windows.Forms.Textbox
    $BoxPathPCDst.Location = New-Object System.Drawing.point(37,100)
    $BoxPathPCDst.Size = New-Object System.Drawing.Size(200,20)
    $BoxPathPCDst.Font = $font
    $BoxPathPCDst.Text = ""
    $form.Controls.Add($BoxPathPCDst)

    $LabelUser = New-Object System.Windows.Forms.Label
    $LabelUser.Location = New-Object System.Drawing.Size(37,140) 
    $LabelUser.Size = New-Object System.Drawing.Size(200,20)
    $LabelUser.Font = $font
    $LabelUser.Text = "Username Profile:"
    $form.Controls.Add($LabelUser)
    
    $BoxUser = New-Object System.Windows.Forms.Textbox
    $BoxUser.Location = New-Object System.Drawing.point(37,160)
    $BoxUser.Size = New-Object System.Drawing.Size(200,20)
    $BoxUser.Font = $font
    $BoxUser.Text = ""
    $form.Controls.Add($BoxUser)

    $ButtonMigrateUserProfile = New-Object System.Windows.Forms.Button
    $ButtonMigrateUserProfile.Text = "Migrate User Profile"
    $ButtonMigrateUserProfile.Location = New-Object System.Drawing.point(37,205)
    $ButtonMigrateUserProfile.Size = New-Object System.Drawing.Size(200,35)
    $ButtonMigrateUserProfile.Font = $font
    $ButtonMigrateUserProfile.ForeColor = "White"
	$ButtonMigrateUserProfile.BackColor = "Black"
    $ButtonMigrateUserProfile.Add_Click({MigrateUserProfile $form.Close()})
    $form.Controls.Add($ButtonMigrateUserProfile)

    # Show form
    $form.ShowDialog()
}