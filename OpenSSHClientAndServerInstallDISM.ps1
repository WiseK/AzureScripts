# Create the OpenSSH folder if it does not exist
$folderPath = "C:\OpenSSH"
if (-Not (Test-Path $folderPath)) {
    New-Item -ItemType Directory -Path $folderPath
}

# Define URLs and destination paths for the OpenSSH packages
$clientUrl = "https://github.com/WiseK/AzureScripts/raw/b2c55fe961224824b005d54f0b6dbc7bc59c4b4d/OpenSSH-Client-Package~31bf3856ad364e35~amd64~~.cab"
$clientDestPath = "$folderPath\OpenSSH-Client-Package~31bf3856ad364e35~amd64~~.cab"
$serverUrl = "https://github.com/WiseK/AzureScripts/raw/281487d64b5e00a207595bbad6497f6dbf76a877/OpenSSH-Server-Package~31bf3856ad364e35~amd64~~.cab"
$serverDestPath = "$folderPath\OpenSSH-Server-Package~31bf3856ad364e35~amd64~~.cab"

# Download the CAB files
Invoke-WebRequest -Uri $clientUrl -OutFile $clientDestPath
Invoke-WebRequest -Uri $serverUrl -OutFile $serverDestPath

# Run DISM commands to add the OpenSSH Client and Server capabilities
$clientInstallResult = dism /Online /Add-Capability /CapabilityName:OpenSSH.Client~~~~0.0.1.0 /source:C:\OpenSSH /LimitAccess
$serverInstallResult = dism /Online /Add-Capability /CapabilityName:OpenSSH.Server~~~~0.0.1.0 /source:C:\OpenSSH /LimitAccess

# Check if both DISM commands were successful
if ($clientInstallResult.ExitCode -eq 0 -and $serverInstallResult.ExitCode -eq 0) {
    # If successful, delete the OpenSSH folder and its contents
    Remove-Item -Path $folderPath -Recurse -Force
} else {
    Write-Host "Error: Installation failed. Client install exit code: $($clientInstallResult.ExitCode), Server install exit code: $($serverInstallResult.ExitCode)."
}
