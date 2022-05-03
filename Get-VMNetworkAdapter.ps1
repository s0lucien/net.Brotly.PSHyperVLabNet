. .\Encode-Text-b64.ps1

$GetVMNetworkAdapter_scriptBlockToInject = {
    $VMNetworkAdapters = Get-VMNetworkAdapter -VMName $vm_name -Verbose
    $ser = [System.Management.Automation.PSSerializer]::Serialize($VMNetworkAdapters)
    $ser | Out-File "$(Get-Location)\Get-VMNetworkAdapter.PSSerialized"
    $VMNetworkAdapters
}

function PSHyperVLabNet\Get-VMNetworkAdapter($VMName) {
    $scriptBlockToInject = $GetVMNetworkAdapter_scriptBlockToInject.ToString() `
        -replace '\$vm_name', "`"$VMName`""
    $encodedCommand = Encode-Text-b64 -Text $scriptBlockToInject.ToString()
    & $PSScriptRoot\execute-NoUAC-shell.ps1 -codeStringToInject "pwsh -WorkingDirectory '$PSScriptRoot\shell\' -EncodedCommand $encodedCommand"
    $VMNetworkAdapters_out = Get-Content "$PSScriptRoot\shell\Get-VMNetworkAdapter.PSSerialized"
    $VMNetworkAdapters =[System.Management.Automation.PSSerializer]::Deserialize($VMNetworkAdapters_out)
    $VMNetworkAdapters
}

# $VMNetworkAdapters = PSHyperVLabNet\Get-VMNetworkAdapter -VMName "rpi"
# $VMNetworkAdapters
