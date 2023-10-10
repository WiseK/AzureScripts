$results = @()

# Define the names of the target resource groups
$targetResourceGroups = @("RG1", "RG2")  # Modify the names accordingly

foreach ($rgName in $targetResourceGroups) {
    # Get VMs for the current resource group
    $vmsInRG = Get-AzVM -ResourceGroupName $rgName

    foreach ($vm in $vmsInRG) {
        $instanceView = Get-AzVM -ResourceGroupName $vm.ResourceGroupName -Name $vm.Name -Status
        if ($instanceView.HyperVGeneration) {
            $gen = $instanceView.HyperVGeneration
        } else {
            $gen = "V1"
        }

        $obj = [PSCustomObject]@{
            VMname     = $vm.Name
            Generation = $gen
        }

        $results += $obj

        # If it's a Gen2 VM, then apply the Update-AzVM command to it
        if ($gen -eq "V2") {
            $vm | Update-AzVM -SecurityType TrustedLaunch -EnableSecureBoot $true -EnableVtpm $true
        }
    }
}

$results | Format-Table -AutoSize
