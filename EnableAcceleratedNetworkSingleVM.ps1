# Azure login (if not already logged in)
Login-AzAccount

# Parameters
$resourceGroupName = "RG"
$vmName = "AVD"

# Get the VM
$vm = Get-AzVM -ResourceGroupName $resourceGroupName -Name $vmName

# Check if VM is deallocated
$vmStatus = Get-AzVM -ResourceGroupName $resourceGroupName -Name $vmName -Status
if ($vmStatus.Statuses[1].Code -ne 'PowerState/deallocated') {
    Write-Output "The VM must be deallocated before enabling Accelerated Networking. Please deallocate the VM and try again."
    exit
}

# Get NIC associated with the VM
$nic = Get-AzNetworkInterface -ResourceId $vm.NetworkProfile.NetworkInterfaces[0].Id

# Enable Accelerated Networking
$nic.EnableAcceleratedNetworking = $true
$nic | Set-AzNetworkInterface

Write-Output "Accelerated Networking has been enabled on $vmName."
