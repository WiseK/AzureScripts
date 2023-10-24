# Define paths for bookmarks
$chromeBookmarksPath = "$env:LOCALAPPDATA\Google\Chrome\User Data\Default\Bookmarks"
$edgeBookmarksPath = "$env:LOCALAPPDATA\Microsoft\Edge\User Data\Default\Bookmarks"

# Dynamically retrieve OneDrive path
$OneDriveRegistryPaths = Get-ChildItem -Path "HKCU:\Software\Microsoft\OneDrive\Accounts"
$OneDrivePath = foreach ($path in $OneDriveRegistryPaths) {
    try {
        Get-ItemPropertyValue -Path $path.PSPath -Name "UserFolder" -ErrorAction Stop
    } catch {
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

# Backup function
function Backup-Bookmarks {
    param (
        [string]$sourcePath,
        [string]$backupName
    )
    if (Test-Path $sourcePath) {
        Copy-Item -Path $sourcePath -Destination "$backupPath\$backupName" -Force
        Write-Output "Backup for $backupName completed successfully!"
    } else {
        Write-Error "Could not find the bookmarks file at $sourcePath."
    }
}

# Backup Chrome and Edge bookmarks to OneDrive
Backup-Bookmarks -sourcePath $chromeBookmarksPath -backupName "ChromeBookmarksBackup.json"
Backup-Bookmarks -sourcePath $edgeBookmarksPath -backupName "EdgeBookmarksBackup.json"
