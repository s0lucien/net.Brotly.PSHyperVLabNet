$ConnectVMNetworkAdapter_scriptBlockToInject = {
    #unbox the variables
    $VMName = $vm_name
    $MacAddress = $mac_address
    $SwitchName = $switch_name
    
    $VM = Get-VM -VMName $VMName
    $initial_VM_state = $VM.State
    $existent_macs = ($VM | Get-VMNetworkAdapter ).MacAddress
    if($existent_macs -contains $MacAddress){
        Write-Host "A Network Interface with MAC address $MacAddress exists for VM $VMName. Connecting vSwitch $SwitchName to it ..."  
        $NICs = $VM | Get-VMNetworkAdapter
        $NICs_to_connect_switch_to = @()
        foreach ($n in $NICs){
            if ($n.MacAddress -eq $MacAddress){
                $NICs_to_connect_switch_to += $n
            }
        }
        Write-Host "Connecting $NICs_to_connect_switch_to -> $SwitchName"
        foreach ($n in $NICs_to_connect_switch_to){
            $n | Connect-VMNetworkAdapter -SwitchName $SwitchName
        } 
        if($?){
            Write-Host "Succesfully connected MAC address $MacAddress -> $SwitchName"
        }
    }else{
        Write-Error "No NIC with MacAddress $MacAddress exists. Make sure that NICs exist before connecting switch to them. Connection unsuccesful"
    }
    $ser = [System.Management.Automation.PSSerializer]::Serialize($?)
    $ser | Out-File "$PSScriptRoot\Connect-VMNetworkAdapter.PSSerialized"
    Write-Host "Done."
}

function PSHyperVLabNet\Connect-VMNetworkAdapter ($VMName, $SwitchName){
    $MacAddressToInject = PSHyperVLabNet\Get-MACAddressFromString "$VMName-$SwitchName"
    $scriptBlockToInject = $ConnectVMNetworkAdapter_scriptBlockToInject.ToString() `
        -replace '\$switch_name', "`"$SwitchName`"" `
        -replace '\$vm_name', "`"$VMName`"" `
        -replace '\$mac_address', "`"$MacAddressToInject`""
    & $PSScriptRoot\execute-NoUAC-shell.ps1 -codeStringToInject $scriptBlockToInject
    $ConnectVMNetworkAdapter_out = Get-Content "$PSScriptRoot\shell\Connect-VMNetworkAdapter.PSSerialized"
    $SHElevate? =[System.Management.Automation.PSSerializer]::Deserialize($ConnectVMNetworkAdapter_out)
    $SHElevate?
}

# PSHyperVLabNet\Connect-VMNetworkAdapter -VMName "rpi" -SwitchName "BrotlyNet_host"
