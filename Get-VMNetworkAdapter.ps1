
$GetVMNetworkAdapter_codeToInject = {
    $VMNetworkAdapters = Get-VMNetworkAdapter -VMName $vm_name -Verbose
    $VMNetworkAdapters |  Export-Csv "$PSScriptRoot\VMNetworkAdapters.csv" -Verbose
    $VMNetworkAdapters
}

function PSHyperVLabNet\Get-VMNetworkAdapter($VMName) {
    $codeToInject = $GetVMNetworkAdapter_codeToInject.ToString() `
        -replace '\$vm_name', "`"$VMName`"" `
  
    & $PSScriptRoot\execute-NoUAC-shell.ps1 -codeStringToInject $codeToInject.ToString()
    $VMNetworkAdapters = Import-Csv -Path "$PSScriptRoot\shell\VMNetworkAdapters.csv"
    $VMNetworkAdapters
}

# $VMNetworkAdapters = PSHyperVLabNet\Get-VMNetworkAdapter -VMName "rpi"
