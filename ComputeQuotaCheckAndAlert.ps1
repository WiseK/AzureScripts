            # List of regions to check
            $locations = @('westus', 'eastus', 'region3', 'region4')

            # Define an array to hold the results
            $results = @()
            $payload = @{
              NotificationType = "Teams"
              message = @()
            }
            # Loop through each location
            foreach ($location in $locations) {
                # Get VM usage for the location
                $usages = Get-AzVMUsage -Location $location

                # Loop through each usage
                foreach ($usage in $usages) {
                    if ($usage.Limit -gt 0) { 
                        $percentageUsed = ($usage.CurrentValue / $usage.Limit) * 100

                        # Show only items that are in use and/or at or above 90% of the limit
                        if ($usage.CurrentValue -gt 0 || $percentageUsed -ge 90) {
                            $results += [PSCustomObject]@{
                                Resource       = $usage.Name.LocalizedValue;
                                Location       = $location;
                                Used           = $usage.CurrentValue;
                                Limit          = $usage.Limit;
                                UsagePercent  = [math]::Round($percentageUsed, 2);
                            }
                        }
                    }
                }
            }
            
            # Display results as a table
            $results | Format-Table -AutoSize
