# PowerShell Script for Configuring Microsoft Defender
#Reference Link https://learn.microsoft.com/en-us/powershell/module/defender/set-mppreference?view=windowsserver2022-ps

# Disabling/Enabling Realtime Monitoring
Set-MpPreference -DisableRealtimeMonitoring $False

# Updating Defender Signatures
Update-MpSignature

# Setting Additional Preferences
Set-MpPreference -DisableArchiveScanning $False
Set-MpPreference -DisableEmailScanning $False
Set-MpPreference -ScanScheduleDay 0
Set-MpPreference -ScanScheduleTime 23:00:00

# Setting Registry Key for Sample Collection
$RegistryPath = "HKLM:\SOFTWARE\Policies\Microsoft\Windows Advanced Threat Protection"
$Name = "AllowSampleCollection"
$Value = 1

# Check if registry path exists, if not, create it
if (-not (Test-Path $RegistryPath)) {
    New-Item -Path $RegistryPath -Force
}

# Set Registry Value
Set-ItemProperty -Path $RegistryPath -Name $Name -Value $Value

# More Preferences
Set-MpPreference -MAPSReporting Advanced
Set-MpPreference -SubmitSamplesConsent 1
Set-MpPreference -EnableNetworkProtection AuditMode
Set-MpPreference -SignatureScheduleDay Everyday
Set-MpPreference -CheckForSignaturesBeforeRunningScan $True
Set-MpPreference -DisableBehaviorMonitoring $False
Set-MpPreference -DisableScriptScanning $False
Set-MpPreference -DisableScanningMappedNetworkDrivesForFullScan $True
Set-MpPreference -DisableScanningNetworkFiles $False
Set-MpPreference -DisableCpuThrottleOnIdleScans $True
Set-MpPreference -DisableRemovableDriveScanning $False
Set-MpPreference -DisableCatchupFullScan $False
Set-MpPreference -DisableCatchupQuickScan $False
Set-MpPreference -DisableCpuThrottleOnIdleScans $False
Set-MpPreference -ScanAvgCPULoadFactor 35
Set-MpPreference -PUAProtection AuditMode
Set-MpPreference -ScanParameters FullScan
Set-MpPreference -EnableLowCpuPriority $True
