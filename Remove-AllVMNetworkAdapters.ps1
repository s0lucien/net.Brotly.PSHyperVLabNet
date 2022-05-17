. .\Encode-Text-b64.ps1

$RemoveAllVMNetworkAdapters_scriptBlockToInject = {
    #unbox the variables
    $VMName = $vm_name
    
    $VM = Get-VM -VMName $VMName
    $initial_VM_state = $VM.State
    $existent_net_adapters = $VM | Get-VMNetworkAdapter -ErrorAction Continue
    if($existent_net_adapters ){
        Write-Host "Removing all NetAdapters from VM $VMName ..."  
        if($VM.State -ne "Off"){
            Write-Host "$VMName is not off. Stopping the VM in order to allow removal of vNICs ..."
            $VM | Stop-VM -Force
        }
        $VM | Get-VMNetworkAdapter | Remove-VMNetworkAdapter -Verbose
        if($?){
            Write-Host "Succesfully removed all Network Adapters from VM $VMName"
        }
        if(($initial_VM_state -eq "Running") -and ($VM.State -eq "Off")){
            Write-Host "$VMName was initially in the 'Running' state and is now 'Off'. Starting it again ..."
            $VM | Start-VM
        }
    }else{
        Write-Host "No NetAdapters exist. No changes will be made."
    }
    $ser = [System.Management.Automation.PSSerializer]::Serialize($?)
    $ser | Out-File "$(Get-Location)\Remove-AllVMNetworkAdapters.PSSerialized"
    Write-Host "Done."
}

function PSHyperVLabNet\Remove-AllVMNetworkAdapters ($VMName ){
    $scriptBlockToInject = $RemoveAllVMNetworkAdapters_scriptBlockToInject.ToString() `
        -replace '\$vm_name', "`"$VMName`""
    $encodedCommand = Encode-Text-b64 -Text $scriptBlockToInject
    & $PSScriptRoot\execute-NoUAC-shell.ps1 -codeStringToInject "pwsh -WorkingDirectory '$PSScriptRoot\shell\' -EncodedCommand $encodedCommand"
    $RemoveVMNetworkAdapter_out = Get-Content "$PSScriptRoot\shell\Remove-AllVMNetworkAdapters.PSSerialized"
    $SHElevate? =[System.Management.Automation.PSSerializer]::Deserialize($RemoveVMNetworkAdapter_out)
    $SHElevate?
}

# PSHyperVLabNet\Remove-AllVMNetworkAdapters -VMName "Ubuntu20.04.4"
