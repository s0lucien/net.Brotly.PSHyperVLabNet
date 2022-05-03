
$RemoveVMSwitch_scriptBlockToInject = {
    Remove-VMSwitch -Name $RemoveVMSwitch_Name -Force -Verbose
    $ser = [System.Management.Automation.PSSerializer]::Serialize($?)
    $ser | Out-File "$(Get-Location)\Remove-VMSwitch.PSSerialized"
}

function PSHyperVLabNet\Remove-VMSwitch ($name){
    $scriptBlockToInject = $RemoveVMSwitch_ScriptBlockToInject.ToString() `
        -replace '\$RemoveVMSwitch_Name', "`"$name`""
    $encodedCommand = Encode-Text-b64 -Text $scriptBlockToInject.ToString()
    & $PSScriptRoot\execute-NoUAC-shell.ps1 -codeStringToInject "pwsh -WorkingDirectory '$PSScriptRoot\shell\' -EncodedCommand $encodedCommand"
    $RemoveVMSwitch_out = Get-Content "$PSScriptRoot\shell\Remove-VMSwitch.PSSerialized"
    $SHElevate? =[System.Management.Automation.PSSerializer]::Deserialize($RemoveVMSwitch_out)
    $SHElevate?
}

# PSHyperVLabNet\Remove-VMSwitch -name "TEST INTERNAL_Internal"
