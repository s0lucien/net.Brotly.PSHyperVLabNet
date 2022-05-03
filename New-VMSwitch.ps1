. .\Encode-Text-b64.ps1

$NewVMSwitch_scriptBlockToInject = {
    $SwitchName = $switch_name
    $SwitchType = $switch_type
   
    New-VMSwitch -Name "$SwitchName`_$SwitchType" -SwitchType $SwitchType -Verbose
    $ser = [System.Management.Automation.PSSerializer]::Serialize($?)
    $ser | Out-File "$(Get-Location)\New-VMSwitch.PSSerialized"
}

#TODO: SWitchType is Internal|Private in CmdletBindings
function PSHyperVLabNet\New-VMSwitch ($SwitchName, $SwitchType){
    $scriptBlockToInject = $NewVMSwitch_ScriptBlockToInject.ToString() `
        -replace '\$switch_name', "`"$SwitchName`"" `
        -replace '\$switch_type', "`"$SwitchType`""
    $encodedCommand = Encode-Text-b64 -Text $scriptBlockToInject
    & $PSScriptRoot\execute-NoUAC-shell.ps1 -codeStringToInject "pwsh -WorkingDirectory '$PSScriptRoot\shell\' -EncodedCommand $encodedCommand"
    $NewVMSwitch_out = Get-Content "$PSScriptRoot\shell\New-VMSwitch.PSSerialized"
    $SHElevate? =[System.Management.Automation.PSSerializer]::Deserialize($NewVMSwitch_out)
    $SHElevate?
}

# PSHyperVLabNet\New-VMSwitch -SwitchName "DEMO PRIVATE" -SwitchType "Private"
# PSHyperVLabNet\New-VMSwitch -SwitchName "DEMO INTERNAL" -SwitchType "Internal"

