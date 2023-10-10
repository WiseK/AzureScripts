#1. We will first get the device name using the $env:COMPUTERNAME environment variable.
#2. Then we will search through the Azure subscription to locate a VM with that name.
#3. Once we find the VM, we can retrieve the resource group associated with that VM.

# Import the necessary module
#Import-Module Az

# Login to your Azure account
#Login-AzAccount

# Get local computer name
$deviceName = $env:COMPUTERNAME

# Find the VM in the Azure subscription that matches the local device name
$vmInfo = Get-AzVM | Where-Object { $_.Name -eq $deviceName }

if (-not $vmInfo) {
    Write-Error "No VM found in the Azure subscription with the name $deviceName"
    exit
}

$resourceGroupName = $vmInfo.ResourceGroupName
$vmName = $vmInfo.Name

# Uninstall the MDE.Windows extension
$MDEExtensionName = "MDE.Windows"
Remove-AzVMExtension -ResourceGroupName $resourceGroupName -VMName $vmName -Name $MDEExtensionName

# Uninstall the MicrosoftMonitoringAgent extension
$monitoringExtensionName = "MicrosoftMonitoringAgent"
Remove-AzVMExtension -ResourceGroupName $resourceGroupName -VMName $vmName -Name $monitoringExtensionName

Write-Host "Extensions uninstalled successfully from VM $vmName in resource group $resourceGroupName"
