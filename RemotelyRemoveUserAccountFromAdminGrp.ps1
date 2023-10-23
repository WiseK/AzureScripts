# Specify the user account and virtual machine name
$UserAccounts = @('UserAccount')
$VirtualMachineNames = @('HostName')

# Add FQDN to the VMName
$domainName = ".domain.com"

foreach ($vmName in $VirtualMachineNames) {
    Write-Output "Processing VM: $vmName"

    $fqdn = $vmName + $domainName

    # Verify Host Name is correct
    Write-Output "FQDN: $fqdn"

    # Initialize a variable for the number of retries
    $retryCount = 0

    # Initialize the test connection result
    $testConnection = $null

    # Try to check the connection up to 4 times
    while ($retryCount -lt 4 -and ($null -eq $testConnection -or !$testConnection.TcpTestSucceeded)) {
        $testConnection = Test-NetConnection -ComputerName $fqdn -CommonTCPPort RDP

        if (!$testConnection.TcpTestSucceeded) {
            Write-Output "Connection failed, retrying... ($retryCount)"
            $retryCount++
            Start-Sleep -Seconds 5 # optional delay before retry
        }
    }

    if ($testConnection.TcpTestSucceeded) {
        # Create a new PSSession to the target VM
        $session = New-PSSession -ComputerName $fqdn

        # Invoke the scriptblock on the remote session
        foreach ($userAccount in $UserAccounts) {
            Write-Output "Removing $userAccount from $vmName"

            Invoke-Command -Session $session -ScriptBlock {
                param($UserAccount)

                # Get the local administrators group
                $AdminGroup = [ADSI]("WinNT://./Administrators")
                
                # Get the user object for the specified username
                $User = [ADSI]("WinNT://$UserAccount")
                
                # Remove the user from the administrators group
                $AdminGroup.Remove($User.Path)
            } -ArgumentList $userAccount
        }
        # Close the session
        Remove-PSSession -Session $session
    } else {
        Write-Output "Cannot connect to $fqdn after 4 retries"
    }
}
