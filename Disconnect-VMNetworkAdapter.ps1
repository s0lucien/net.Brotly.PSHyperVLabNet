$DisconnectVMNetworkAdapter_scriptBlockToInject = {
    #unbox the variables
    $VMName = $vm_name
    $MacAddress = $mac_address
    
    $VM = Get-VM -VMName $VMName
    $initial_VM_state = $VM.State
    $existent_macs = ($VM | Get-VMNetworkAdapter ).MacAddress
    if($existent_macs -contains $MacAddress){
        Write-Host "A Network Interface with MAC address $MacAddress exists for VM $VMName. Will disconnect it from its vSwitch  ..."  
        $NICs = $VM | Get-VMNetworkAdapter
        $NICs_to_disconnect_from_switch = @()
        foreach ($n in $NICs){
            if ($n.MacAddress -eq $MacAddress){
                $NICs_to_disconnect_from_switch += $n
            }
        }
        Write-Host "Disconnecting $NICs_to_disconnect_from_switch ..."
        foreach ($n in $NICs_to_disconnect_from_switch){
            $n | Disconnect-VMNetworkAdapter
        } 
        if($?){
            Write-Host "Succesfully Disconnected NIC with MAC address $MacAddress"
        }
    }else{
        Write-Error "No NIC with MacAddress $MacAddress exists. Make sure that NICs exist before connecting switch to them. Disconnection unsuccesful"
    }
    $ser = [System.Management.Automation.PSSerializer]::Serialize($?)
    $ser | Out-File "$PSScriptRoot\Disconnect-VMNetworkAdapter.PSSerialized"
    Write-Host "Done."
}

function PSHyperVLabNet\Disconnect-VMNetworkAdapter ($VMName, $SwitchName){
    $MacAddressToInject = PSHyperVLabNet\Get-MACAddressFromString "$VMName-$SwitchName"
    $scriptBlockToInject = $DisconnectVMNetworkAdapter_scriptBlockToInject.ToString() `
        -replace '\$vm_name', "`"$VMName`"" `
        -replace '\$mac_address', "`"$MacAddressToInject`""
    & $PSScriptRoot\execute-NoUAC-shell.ps1 -codeStringToInject $scriptBlockToInject
    $DisconnectVMNetworkAdapter_out = Get-Content "$PSScriptRoot\shell\Disconnect-VMNetworkAdapter.PSSerialized"
    $SHElevate? =[System.Management.Automation.PSSerializer]::Deserialize($DisconnectVMNetworkAdapter_out)
    $SHElevate?
}

# PSHyperVLabNet\Disconnect-VMNetworkAdapter -VMName "rpi" -SwitchName "BrotlyNet_host"
