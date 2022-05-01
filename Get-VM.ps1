
$GetVM_codeToInject = {
    $VMs = Get-VM -Verbose
    $ser = [System.Management.Automation.PSSerializer]::Serialize($VMs)
    $ser | Out-File "$PSScriptRoot\VMs.PSSerialized"
    $VMs
}

function PSHyperVLabNet\Get-VM {
    & $PSScriptRoot\execute-NoUAC-shell.ps1 -timeout 2 -codeStringToInject $GetVM_codeToInject.ToString()
    $VMs_out = Get-Content "$PSScriptRoot\shell\VMs.PSSerialized"
    $VMs =[System.Management.Automation.PSSerializer]::Deserialize($VMs_out)
    $VMs
}

# $VMs = PSHyperVLabNet\Get-VM
