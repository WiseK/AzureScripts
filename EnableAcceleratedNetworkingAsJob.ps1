$allVMs = Get-AzVM

foreach ($vm in $allVMs) {
    # Utilizing -AsJob to send each VM processing as a separate background job
    Start-Job -ScriptBlock {
        param($vm)

        $nic = Get-AzNetworkInterface -ResourceId $vm.NetworkProfile.NetworkInterfaces[0].Id
        
        Write-Output "Processing VM $($vm.Name) in Resource Group $($vm.ResourceGroupName) with NIC named $($nic.Name) having ID $($nic.Id)."

        if ($nic.EnableAcceleratedNetworking -eq $true) {
            Write-Output "Accelerated Networking is already enabled on $($vm.Name) in Resource Group $($vm.ResourceGroupName). Skipping..."
            return
        }

        $vmStatus = Get-AzVM -ResourceGroupName $vm.ResourceGroupName -Name $vm.Name -Status
        if ($vmStatus.Statuses[1].Code -ne 'PowerState/deallocated') {
            Write-Output "The VM $($vm.Name) in Resource Group $($vm.ResourceGroupName) must be deallocated before enabling Accelerated Networking. Please deallocate the VM and try again."
            return
        }

        #$nic.EnableAcceleratedNetworking = $true
        #$nic | Set-AzNetworkInterface

        Write-Output "Accelerated Networking has been enabled on $($vm.Name) in Resource Group $($vm.ResourceGroupName)."

    } -ArgumentList $vm # passing the $vm object to the job
}

# Optionally, wait for all jobs to complete and then retrieve the output
Get-Job | Wait-Job | Receive-Job

# Clean up the completed jobs
Get-Job | Remove-Job
