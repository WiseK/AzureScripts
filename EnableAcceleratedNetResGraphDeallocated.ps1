<#
.SYNOPSIS
This script retrieves deallocated Virtual Machines (VMs) using Azure Resource Graph and checks/enables Accelerated Networking (AN) on their network interfaces (NICs).

.DESCRIPTION
1. The script uses the 'Search-AzGraph' cmdlet to find all deallocated VMs by querying the Azure Resource Graph. The specific query is defined in the `$query` variable.
2. It implements pagination logic to handle the retrieval of large numbers of VMs, making successive calls to 'Search-AzGraph' to retrieve all VMs in batches of size defined in `$first`.
3. For each deallocated VM retrieved, it finds the associated NIC, checks whether AN is enabled, and if it is not, enables it. Note that the NIC enabling is commented out.
4. It outputs the VMs for which AN was not enabled in a table format.

.PARAMETERS
- `$first`: Number of VMs to retrieve in each batch. Defaults to 1000.
- `$query`: A query to find deallocated VMs and project the necessary properties.

.NOTES
- Ensure Azure PowerShell and Az.ResourceGraph modules are installed and that you're authenticated to Azure before running.
- Validate and test thoroughly in a safe environment before running in production.

#>

# Parameters
$first = 1000  # First 1000 VMs

# Query: Adjusted for simplicity
$query = @"
Resources
| where type =~ 'microsoft.compute/virtualmachines'
| where properties.extended.instanceView.powerState.code == 'PowerState/deallocated'
| project vmName=name, resourceGroup=resourceGroup, nicId=properties.networkProfile.networkInterfaces[0].id
"@

$allDeallocatedVMs = @()
$skip = $null

do {
    if($null -eq $skip) {
        $deallocatedVMs = Search-AzGraph -Query $query -First $first
    } else {
        $deallocatedVMs = Search-AzGraph -Query $query -First $first -Skip $skip
    }
    
    if($deallocatedVMs -eq $null -or $deallocatedVMs.Count -eq 0){
        Write-Output "No more VMs found."
        break
    }

    $allDeallocatedVMs += $deallocatedVMs
    Write-Output "Retrieved $($allDeallocatedVMs.Count) VMs so far..."
    
    $skip = $allDeallocatedVMs.Count
} while ($true)

Write-Output "Retrieved a total of $($allDeallocatedVMs.Count) VMs."

# Processing
$vmsWithoutAN = @()

foreach ($vm in $allDeallocatedVMs) {
    $nicId = $vm.nicId
    $nicName = ($nicId -split '/')[-1]
    $rgName = $vm.resourceGroup
    
    $nic = Get-AzNetworkInterface -ResourceGroupName $rgName -Name $nicName
    
    if (-not $nic.EnableAcceleratedNetworking) {
        $vmsWithoutAN += $vm
        Write-Output "Enabling Accelerated Networking on NIC: $nicName for VM: $($vm.vmName) in Resource Group: $rgName..."
        #$nic.EnableAcceleratedNetworking = $true
        #Set-AzNetworkInterface -NetworkInterface $nic
    }
}

# Output VMs that were without AN
$vmsWithoutAN | Format-Table vmName, resourceGroup
