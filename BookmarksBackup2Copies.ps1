# Wait and check for OneDrive and FileSyncHelper processes for up to 3 minutes
$retryCount = 0
$foundProcesses = $false

while ($retryCount -lt 6 -and -not $foundProcesses) {
    if ((Get-Process -Name "OneDrive" -ErrorAction SilentlyContinue) -and (Get-Process -Name "FileSyncHelper" -ErrorAction SilentlyContinue)) {
        $foundProcesses = $true
    }
    else {
        # Wait for 30 seconds before retrying
        Start-Sleep -Seconds 30
        $retryCount++
    }
}

if (-not $foundProcesses) {
    Write-Output "Either OneDrive or FileSyncHelper is not running even after waiting for 3 minutes. Exiting the script."
    return
}

# Define paths for bookmarks
$chromeBookmarksPath = "$env:LOCALAPPDATA\Google\Chrome\User Data\Default\Bookmarks"
$edgeBookmarksPath = "$env:LOCALAPPDATA\Microsoft\Edge\User Data\Default\Bookmarks"

# Dynamically retrieve OneDrive path
$OneDriveRegistryPaths = Get-ChildItem -Path "HKCU:\Software\Microsoft\OneDrive\Accounts"
$OneDrivePath = foreach ($path in $OneDriveRegistryPaths) {
    try {
        Get-ItemPropertyValue -Path $path.PSPath -Name "UserFolder" -ErrorAction Stop
    }
    catch {
        # Ignore if the key doesn't have the UserFolder property
    }
}

# If multiple OneDrive paths are found, use the first one (you can adjust this logic as needed)
if ($OneDrivePath -is [array]) {
    $OneDrivePath = $OneDrivePath[0]
}

$backupPath = "$OneDrivePath\BookmarksBackup"

# Create backup directory in OneDrive if it doesn't exist
if (-not (Test-Path $backupPath)) {
    New-Item -Path $backupPath -ItemType Directory
}

function Backup-Bookmarks {
    param (
        [string]$sourcePath,
        [string]$backupBaseName
    )

    # Generate the backup filename with timestamp
    $timestamp = Get-Date -Format "yyyyMMddHHmmss"
    $backupFileName = "${backupBaseName}Backup_${timestamp}.json"
    $backupFullPath = Join-Path -Path $backupPath -ChildPath $backupFileName

    if (Test-Path $sourcePath) {
        # Create the new backup
        Copy-Item -Path $sourcePath -Destination $backupFullPath -Force
        Write-Output "Backup for $backupFileName completed successfully!"
        
        # Get a list of all backup files for this browser, sorted oldest to newest
        $backupFiles = Get-ChildItem -Path $backupPath -Filter "${backupBaseName}Backup_*.json" | Sort-Object LastWriteTime

        # If there are more than 2 backup files, remove the oldest ones until only 2 remain
        while ($backupFiles.Count -gt 2) {
            $oldestBackupFile = $backupFiles[0]
            Remove-Item -Path $oldestBackupFile.FullName -Force
            Write-Output "Removed old backup: $($oldestBackupFile.Name)"
            $backupFiles = $backupFiles | Where-Object { $_.Name -ne $oldestBackupFile.Name }
        }
    }
    else {
        Write-Error "Could not find the bookmarks file at $sourcePath."
    }
}
# Backup Chrome and Edge bookmarks to OneDrive with timestamp
Backup-Bookmarks -sourcePath $chromeBookmarksPath -backupBaseName "ChromeBookmarks"
Backup-Bookmarks -sourcePath $edgeBookmarksPath -backupBaseName "EdgeBookmarks"
