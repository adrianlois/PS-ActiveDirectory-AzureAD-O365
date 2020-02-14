$FileImportCSV = "file.csv"

Import-Csv $FileImportCSV | Foreach-Object {

$Path = $_."Path"
$PathCheck = Test-Path -Path $Path

# Check if the directory exists
    If ($PathCheck -eq $True) {
        Write-Host "[++] The directory exists: $Path"
    } Else { 
		New-Item -ItemType Directory -Path "$Path"
        Write-Host "`n[+] The directory was created successfully: $Path"
    }
}

# Another way to use Test-Path
# If (-not (Test-Path -Path $Path) { ... }