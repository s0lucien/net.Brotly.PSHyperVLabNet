
$NewVMSwitch_scriptBlockToInject = {
    New-VMSwitch -Name $NewVMSwitch_Name -SwitchType $NewVMSwitch_SwitchType -Verbose
    $ser = [System.Management.Automation.PSSerializer]::Serialize($?)
    $ser | Out-File "$PSScriptRoot\New-VMSwitch.PSSerialized"
}

function PSHyperVLabNet\New-VMSwitch ($name, $type){
    $codeToInject = $NewVMSwitch_ScriptBlockToInject.ToString() `
        -replace '\$NewVMSwitch_Name', "`"$name`"" `
        -replace '\$NewVMSwitch_SwitchType', $type
    & $PSScriptRoot\execute-NoUAC-shell.ps1 -codeStringToInject $codeToInject
    $NewVMSwitch_out = Get-Content "$PSScriptRoot\shell\New-VMSwitch.PSSerialized"
    $SHElevate? =[System.Management.Automation.PSSerializer]::Deserialize($NewVMSwitch_out)
    $SHElevate?
}

# PSHyperVLabNet\New-VMSwitch -name "DEMO PRIVATE" -type "Private"
# PSHyperVLabNet\New-VMSwitch -name "DEMO INTERNAL" -type "Internal"

