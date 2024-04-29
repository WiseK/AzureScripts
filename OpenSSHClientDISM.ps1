# Create the OpenSSH folder if it does not exist
$folderPath = "C:\OpenSSH"
if (-Not (Test-Path $folderPath)) {
    New-Item -ItemType Directory -Path $folderPath
}

# Define URL and destination path for the OpenSSH Client package
$clientUrl = "https://github.com/WiseK/AzureScripts/raw/b2c55fe961224824b005d54f0b6dbc7bc59c4b4d/OpenSSH-Client-Package~31bf3856ad364e35~amd64~~.cab"
$clientDestPath = "$folderPath\OpenSSH-Client-Package~31bf3856ad364e35~amd64~~.cab"

# Download the CAB file
Invoke-WebRequest -Uri $clientUrl -OutFile $clientDestPath

# Run DISM command to add the OpenSSH Client capability
dism /Online /Add-Capability /CapabilityName:OpenSSH.Client~~~~0.0.1.0 /source:C:\OpenSSH /LimitAccess

# Check if the DISM command was successful using the $LASTEXITCODE automatic variable
if ($LASTEXITCODE -eq 0) {
    # If successful, delete the OpenSSH folder and its contents
    Remove-Item -Path $folderPath -Recurse -Force
} else {
    Write-Host "Error: OpenSSH Client installation failed with exit code $LASTEXITCODE."
}
