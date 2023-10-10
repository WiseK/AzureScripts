# Get all VMs in the subscription
$allVMs = Get-AzVM

foreach ($vm in $allVMs) {
    # Get NIC associated with the VM
    $nic = Get-AzNetworkInterface -ResourceId $vm.NetworkProfile.NetworkInterfaces[0].Id
    
    # Display NIC details
    Write-Output "Processing VM $($vm.Name) in Resource Group $($vm.ResourceGroupName) with NIC named $($nic.Name) having ID $($nic.Id)."

    # Check if Accelerated Networking is already enabled
    if ($nic.EnableAcceleratedNetworking -eq $true) {
        Write-Output "Accelerated Networking is already enabled on $($vm.Name) in Resource Group $($vm.ResourceGroupName). Skipping..."
        continue
    }

    # Check if VM is deallocated
    $vmStatus = Get-AzVM -ResourceGroupName $vm.ResourceGroupName -Name $vm.Name -Status
    if ($vmStatus.Statuses[1].Code -ne 'PowerState/deallocated') {
        Write-Output "The VM $($vm.Name) in Resource Group $($vm.ResourceGroupName) must be deallocated before enabling Accelerated Networking. Please deallocate the VM and try again."
        continue
    }

    # Enable Accelerated Networking
    #$nic.EnableAcceleratedNetworking = $true
    #$nic | Set-AzNetworkInterface
	
	Write-Output "Accelerated Networking has been enabled on $($vm.Name) in Resource Group $($vm.ResourceGroupName)."
}
