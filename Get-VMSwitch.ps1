
$GetVMSwitch_codeToInject = {
    $VMSwitches = Get-VMSwitch -Verbose
    $VMSwitches |  Export-Csv "$PSScriptRoot\VMSwitches.csv" -Verbose
    $VMSwitches
}

function PSHyperVLabNet\Get-VMSwitch {
    & $PSScriptRoot\execute-NoUAC-shell.ps1 -codeStringToInject $GetVMSwitch_codeToInject.ToString()
    $VMSwitches = Import-Csv -Path "$PSScriptRoot\shell\VMSwitches.csv"
    $VMSwitches
}

# $VMSwitches = PSHyperVLabNet\Get-VMSwitch
