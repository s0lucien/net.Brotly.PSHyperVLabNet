
$GetVM_codeToInject = {
    $VMs = Get-VM
    $VMs |  Export-Csv "$PSScriptRoot\VMs.csv" -Verbose
    $VMs
}

function PSHyperVLabNet\Get-VM {
    & $PSScriptRoot\execute-NoUAC-shell.ps1 -timeout 2 -codeStringToInject $GetVM_codeToInject.ToString()
    $VMs = Import-Csv -Path "$PSScriptRoot\shell\VMs.csv"
    $VMs
}
