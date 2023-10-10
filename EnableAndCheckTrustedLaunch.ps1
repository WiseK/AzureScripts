#Enable
Get-AzVM -ResourceGroupName RG -VMName AVD `
			| Update-AzVM -SecurityType TrustedLaunch `
				-EnableSecureBoot $true -EnableVtpm $true

# Following command output should be `TrustedLaunch`
(Get-AzVM -ResourceGroupName RG -VMName AVD `
    | Select-Object -Property SecurityProfile `
        -ExpandProperty SecurityProfile).SecurityProfile.SecurityType

# Following command output should return `SecureBoot` and `vTPM` settings
(Get-AzVM -ResourceGroupName RG -VMName AVD `
    | Select-Object -Property SecurityProfile `
        -ExpandProperty SecurityProfile).SecurityProfile.Uefisettings
