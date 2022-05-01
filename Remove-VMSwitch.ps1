
$RemoveVMSwitch_scriptBlockToInject = {
    Remove-VMSwitch -Name $RemoveVMSwitch_Name -Force -Verbose
    $ser = [System.Management.Automation.PSSerializer]::Serialize($?)
    $ser | Out-File "$PSScriptRoot\Remove-VMSwitch.PSSerialized"
}

function PSHyperVLabNet\Remove-VMSwitch ($name){
    $codeToInject = $RemoveVMSwitch_ScriptBlockToInject.ToString() `
        -replace '\$RemoveVMSwitch_Name', "`"$name`""
    & $PSScriptRoot\execute-NoUAC-shell.ps1 -codeStringToInject $codeToInject
    $RemoveVMSwitch_out = Get-Content "$PSScriptRoot\shell\Remove-VMSwitch.PSSerialized"
    $SHElevate? =[System.Management.Automation.PSSerializer]::Deserialize($RemoveVMSwitch_out)
    $SHElevate?
}

# PSHyperVLabNet\Remove-VMSwitch -name "DEMO PRIVATE"
# PSHyperVLabNet\Remove-VMSwitch -name "DEMO INTERNAL"
