
$GetVMSwitch_codeToInject = {
    $VMSwitches = Get-VMSwitch
    $VMSwitches |  Export-Csv "$PSScriptRoot\VMSwitches.csv" -Verbose
    $VMSwitches
}

function PSHyperVLabNet\Get-VMSwitch {
    & $PSScriptRoot\execute-NoUAC-shell.ps1 -timeout 2 -codeStringToInject $GetVMSwitch_codeToInject.ToString()
    $VMSwitches = Import-Csv -Path "$PSScriptRoot\shell\VMSwitches.csv"
    $VMSwitches
}

#$VMSwitches = PSHyperVLabNet\Get-VMSwitch
