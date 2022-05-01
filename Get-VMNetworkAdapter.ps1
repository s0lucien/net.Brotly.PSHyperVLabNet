
$GetVMNetworkAdapter_scriptBlockToInject = {
    $VMNetworkAdapters = Get-VMNetworkAdapter -VMName $vm_name -Verbose
    $ser = [System.Management.Automation.PSSerializer]::Serialize($VMNetworkAdapters)
    $ser | Out-File "$PSScriptRoot\Get-VMNetworkAdapter.PSSerialized"
    $VMNetworkAdapters
}

function PSHyperVLabNet\Get-VMNetworkAdapter($VMName) {
    $scriptBlockToInject = $GetVMNetworkAdapter_scriptBlockToInject.ToString() `
        -replace '\$vm_name', "`"$VMName`"" `
  
    & $PSScriptRoot\execute-NoUAC-shell.ps1 -codeStringToInject $scriptBlockToInject.ToString()
    $VMNetworkAdapters_out = Get-Content "$PSScriptRoot\shell\Get-VMNetworkAdapter.PSSerialized"
    $VMNetworkAdapters =[System.Management.Automation.PSSerializer]::Deserialize($VMNetworkAdapters_out)
    $VMNetworkAdapters
}

# $VMNetworkAdapters = PSHyperVLabNet\Get-VMNetworkAdapter -VMName "rpi"
