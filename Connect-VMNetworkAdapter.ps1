. .\Encode-Text-b64.ps1
. .\Get-MACAddressFromString.ps1

$ConnectVMNetworkAdapter_scriptBlockToInject = {
    #unbox the variables
    $VMName = $vm_name
    $MacAddress = $mac_address
    $SwitchName = $switch_name
    
    $VM = Get-VM -VMName $VMName
    $existent_macs = ($VM | Get-VMNetworkAdapter ).MacAddress
    if($existent_macs -contains $MacAddress){
        Write-Host "A Network Interface with MAC address $MacAddress exists for VM $VMName. Connecting vSwitch $SwitchName to it ..."  
        $NICs = $VM | Get-VMNetworkAdapter | Where-Object {$_.MacAddress -eq $MacAddress} | Connect-VMNetworkAdapter -SwitchName $SwitchName
        if($?){
            Write-Host "Succesfully connected MAC address $MacAddress -> $SwitchName"
        }
    }else{
        Write-Error "No NIC with MacAddress $MacAddress exists. Make sure that NICs exist before connecting switch to them. Connection unsuccesful"
    }
    $ser = [System.Management.Automation.PSSerializer]::Serialize($?)
    $ser | Out-File "$(Get-Location)\Connect-VMNetworkAdapter.PSSerialized"
    Write-Host "Done."
}

function PSHyperVLabNet\Connect-VMNetworkAdapter ($VMName, $SwitchName){
    $MacAddressToInject = PSHyperVLabNet\Get-MACAddressFromString "$VMName-$SwitchName"
    $scriptBlockToInject = $ConnectVMNetworkAdapter_scriptBlockToInject.ToString() `
        -replace '\$switch_name', "`"$SwitchName`"" `
        -replace '\$vm_name', "`"$VMName`"" `
        -replace '\$mac_address', "`"$MacAddressToInject`""
    $encodedCommand = Encode-Text-b64 -Text $scriptBlockToInject.ToString()
    & $PSScriptRoot\execute-NoUAC-shell.ps1 -codeStringToInject "pwsh -WorkingDirectory '$PSScriptRoot\shell\' -EncodedCommand $encodedCommand"
    $ConnectVMNetworkAdapter_out = Get-Content "$PSScriptRoot\shell\Connect-VMNetworkAdapter.PSSerialized"
    $SHElevate? =[System.Management.Automation.PSSerializer]::Deserialize($ConnectVMNetworkAdapter_out)
    $SHElevate?
}

# PSHyperVLabNet\Connect-VMNetworkAdapter -VMName "rpi" -SwitchName "BrotlyNet_host"
