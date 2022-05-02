$RemoveVMNetworkAdapter_scriptBlockToInject = {
    #unbox the variables
    $VMName = $vm_name
    $MacAddress = $mac_address
    
    $VM = Get-VM -VMName $VMName
    $initial_VM_state = $VM.State
    $existent_macs = ($VM | Get-VMNetworkAdapter ).MacAddress
    if($existent_macs -contains $MacAddress){
        Write-Host "A Network Interface with MAC address $MacAddress already exists for VM $VMName. Deleting it ..."  
        if($VM.State -ne "Off"){
            Write-Host "$VMName is not off. Stopping the VM in order to allow removal of vNICs ..."
            $VM | Stop-VM -Force
        }
        $NICs = $VM | Get-VMNetworkAdapter
        $NICs_to_delete = @()
        foreach ($n in $NICs){
            if ($n.MacAddress -eq $MacAddress){
                $NICs_to_delete += $n
            }
        }
        Write-Host "Going to remove NICs: $NICs_to_delete"
        foreach ($n in $NICs_to_delete){
            $n | Remove-VMNetworkAdapter
        } 
        if($?){
            Write-Host "Succesfully removed all Network Interfaces with MAC address $MacAddress"
        }
        if(($initial_VM_state -eq "Running") -and ($VM.State -eq "Off")){
            Write-Host "$VMName was initially in the 'Running' state and is now 'Off'. Starting it again ..."
            $VM | Start-VM
        }
    }else{
        Write-Host "No NIC with MacAddress $MacAddress exists. No changes will be made."
    }
    $ser = [System.Management.Automation.PSSerializer]::Serialize($?)
    $ser | Out-File "$PSScriptRoot\Remove-VMNetworkAdapter.PSSerialized"
    Write-Host "Done."
}

function PSHyperVLabNet\Remove-VMNetworkAdapter ($VMName, $SwitchName){
    $MacAddressToInject = PSHyperVLabNet\Get-MACAddressFromString "$VMName-$SwitchName"
    $scriptBlockToInject = $RemoveVMNetworkAdapter_scriptBlockToInject.ToString() `
        -replace '\$vm_name', "`"$VMName`"" `
        -replace '\$mac_address', "`"$MacAddressToInject`""
    & $PSScriptRoot\execute-NoUAC-shell.ps1 -codeStringToInject $scriptBlockToInject
    $RemoveVMNetworkAdapter_out = Get-Content "$PSScriptRoot\shell\Remove-VMNetworkAdapter.PSSerialized"
    $SHElevate? =[System.Management.Automation.PSSerializer]::Deserialize($RemoveVMNetworkAdapter_out)
    $SHElevate?
}

# PSHyperVLabNet\Remove-VMNetworkAdapter -VMName "rpi" -SwitchName "BrotlyNet_host"
