
$GetVMSwitch_codeToInject = {
    $VMSwitches = Get-VMSwitch -Verbose
    $ser = [System.Management.Automation.PSSerializer]::Serialize($VMSwitches)
    $ser | Out-File "$PSScriptRoot\VMSwitches.PSSerialized"
    $VMSwitches
}

function PSHyperVLabNet\Get-VMSwitch {
    & $PSScriptRoot\execute-NoUAC-shell.ps1 -codeStringToInject $GetVMSwitch_codeToInject.ToString()
    $VMSwitches_out = Get-Content "$PSScriptRoot\shell\VMSwitches.PSSerialized"
    $VMSwitches =[System.Management.Automation.PSSerializer]::Deserialize($VMSwitches_out)
    $VMSwitches
}

# $VMSwitches = PSHyperVLabNet\Get-VMSwitch
