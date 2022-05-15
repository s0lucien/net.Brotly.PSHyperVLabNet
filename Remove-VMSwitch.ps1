
$RemoveVMSwitch_scriptBlockToInject = {
    $RemoveVMSwitchName = $remove_vm_switch_name

    if (Get-VMSwitch -Name $RemoveVMSwitchName -ErrorAction Continue){
        Remove-VMSwitch -Name $RemoveVMSwitchName -Force -Verbose
    }else{
        Write-Host "No switch with name $RemoveVMSwitchName found. Nothing to remove"
    }
    $ser = [System.Management.Automation.PSSerializer]::Serialize($?)
    $ser | Out-File "$(Get-Location)\Remove-VMSwitch.PSSerialized"
}

function PSHyperVLabNet\Remove-VMSwitch ($SwitchName){
    $scriptBlockToInject = $RemoveVMSwitch_ScriptBlockToInject.ToString() `
        -replace '\$remove_vm_switch_name', "`"$SwitchName`""
    $encodedCommand = Encode-Text-b64 -Text $scriptBlockToInject.ToString()
    & $PSScriptRoot\execute-NoUAC-shell.ps1 -codeStringToInject "pwsh -WorkingDirectory '$PSScriptRoot\shell\' -EncodedCommand $encodedCommand"
    $RemoveVMSwitch_out = Get-Content "$PSScriptRoot\shell\Remove-VMSwitch.PSSerialized"
    $SHElevate? =[System.Management.Automation.PSSerializer]::Deserialize($RemoveVMSwitch_out)
    $SHElevate?
}

# PSHyperVLabNet\Remove-VMSwitch -name "vagrant_dummy"
