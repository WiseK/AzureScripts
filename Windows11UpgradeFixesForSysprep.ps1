# These are the fixes we needed to do after upgrading Win10 to Win11 for sysprep to run successfully.
Get-AppXPackage -AllUsers | Foreach {Add-AppxPackage -DisableDevelopmentMode -Register "$($_.InstallLocation)\AppXManifest.xml"}
Restart-Computer -Force

# After reboot, you should run the following commands:

# Step 2: Delete the 'Upgrade' DWORD under 'HKEY_LOCAL_MACHINE\SYSTEM\Setup'
Remove-ItemProperty -Path "HKLM:\SYSTEM\Setup" -Name "Upgrade" -ErrorAction SilentlyContinue

# Step 3: Add the 'CleanUpState' DWORD with value 7 under 'HKEY_LOCAL_MACHINE\SYSTEM\Setup\Status\SysprepStatus'
Set-ItemProperty -Path "HKLM:\SYSTEM\Setup\Status\SysprepStatus" -Name "CleanUpState" -Value 7 -Type DWORD

Write-Host "Registry modifications complete!"
DISM.exe /Online /Cleanup-image /scanhealth
DISM /Online /Cleanup-Image /CheckHealth
DISM /Online /Cleanup-Image /RestoreHealth

#NotepadPlusPlus- Issues with the latest version. Waiting for MS to fix.
Get-AppxPackage -Name *NotepadPlusPlus* | Remove-AppxPackage

Get-AppxPackage -Name *Microsoft.SkypeApp* | Remove-AppxPackage
Get-AppxPackage -Name *Microsoft.XboxApp* | Remove-AppxPackage
#Run Seal Script
#
#Run Sysprep
#sysprep.exe /oobe /generalize /shutdown /mode:vm
