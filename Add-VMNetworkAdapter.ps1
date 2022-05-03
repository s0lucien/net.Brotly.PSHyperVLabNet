. .\Encode-Text-b64.ps1
. .\Get-MACAddressFromString.ps1

$AddVMNetworkAdapter_scriptBlockToInject = {
    #unbox the variables
    $VMName = $vm_name
    $MacAddress = $mac_address
    
    $VM = Get-VM -VMName $VMName
    $initial_VM_state = $VM.State
    $existent_macs = ($VM | Get-VMNetworkAdapter ).MacAddress
    if($existent_macs -contains $MacAddress){
      Write-Host "A Network Interface with MAC address $MacAddress already exists for VM $VMName. No changes required."  
    }
    else{
        if($VM.State -ne "Off"){
            Write-Host "$VMName is not off. Stopping the VM in order to allow adding vNICs ..."
            $VM | Stop-VM -Force 
        }
        $VM | Add-VMNetworkAdapter -StaticMacAddress $MacAddress
        if($?){
            Write-Host "Succesfully added a Network Interface with MAC address $MacAddress"
        }
        if(($initial_VM_state -eq "Running") -and ($VM.State -eq "Off")){
            Write-Host "$VMName was initially in the 'Running' state and is now 'Off'. Starting it again ..."
            $VM | Start-VM
        }
    }
    $ser = [System.Management.Automation.PSSerializer]::Serialize($?)
    $ser | Out-File "$(Get-Location)\Add-VMNetworkAdapter.PSSerialized"
    Write-Host "Done."
}

function PSHyperVLabNet\Add-VMNetworkAdapter ($VMName, $SwitchName){
    $MacAddressToInject = PSHyperVLabNet\Get-MACAddressFromString "$VMName-$SwitchName"
    $scriptBlockToInject = $AddVMNetworkAdapter_scriptBlockToInject.ToString() `
        -replace '\$vm_name', "`"$VMName`"" `
        -replace '\$mac_address', "`"$MacAddressToInject`""
    $encodedCommand = Encode-Text-b64 -Text $scriptBlockToInject
    & $PSScriptRoot\execute-NoUAC-shell.ps1 -codeStringToInject "pwsh -WorkingDirectory '$PSScriptRoot\shell\' -EncodedCommand $encodedCommand"
    Write-Host "Executed. Retrieving result"
    $AddVMNetworkAdapter_out = Get-Content "$PSScriptRoot\shell\Add-VMNetworkAdapter.PSSerialized"
    $SHElevate? =[System.Management.Automation.PSSerializer]::Deserialize($AddVMNetworkAdapter_out)
    $SHElevate?
}

# PSHyperVLabNet\Add-VMNetworkAdapter -VMName "rpi" -SwitchName "BrotlyNet_host"
