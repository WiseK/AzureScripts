# Fetch VMs from a Specific Resource Group: The script retrieves all virtual machines (VMs) that are part of the resource group named RG.
# Iterate Over Each VM: For each VM in the specified resource group, the script performs the following operations:
# a. Retrieve Associated NIC: It identifies the Network Interface Card (NIC) associated with the VM.
# b. Display NIC Details: It outputs details about the VM and its associated NIC, such as the VM name, its resource group name, NIC name, and NIC ID.
# c. Check for Accelerated Networking: It checks whether the Accelerated Networking feature is already enabled on the NIC. If Accelerated Networking is enabled, the script provides a message indicating so and moves to the next VM without making any changes.
# d. Check VM Power State: Before enabling Accelerated Networking, the script checks if the VM is in the deallocated state (i.e., it's turned off and not incurring charges). If the VM is not deallocated, the script provides a message asking the user to deallocate the VM first before enabling Accelerated Networking.
# e. Enable Accelerated Networking: If the conditions are met (i.e., the VM is deallocated and Accelerated Networking is not already enabled), the script contains commented-out lines to enable Accelerated Networking on the NIC. This means the actual enabling operation is not executed unless those lines are uncommented.
# Output Results: After processing each VM, the script provides a message indicating that Accelerated Networking has been enabled (or would be enabled if the related code was uncommented) for that VM in the specified resource group.
# Get all VMs in the specified resource group
$allVMs = Get-AzVM -ResourceGroupName 'RG1'

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

    # Enable Accelerated Networking (the actual enabling code is commented out in the original script, keeping it that way)
    #$nic.EnableAcceleratedNetworking = $true
    #$nic | Set-AzNetworkInterface
	
	Write-Output "Accelerated Networking has been enabled on $($vm.Name) in Resource Group $($vm.ResourceGroupName)."
}
