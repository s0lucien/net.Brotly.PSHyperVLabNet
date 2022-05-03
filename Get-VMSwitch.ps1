. .\Encode-Text-b64.ps1

$GetVMSwitch_scriptBlockToInject = {
    $VMSwitches = Get-VMSwitch -Verbose
    $ser = [System.Management.Automation.PSSerializer]::Serialize($VMSwitches)
    $ser | Out-File "$(Get-Location)\VMSwitches.PSSerialized"
    $VMSwitches
}

function PSHyperVLabNet\Get-VMSwitch {
    $encodedCommand = Encode-Text-b64 -Text $GetVMSwitch_scriptBlockToInject.ToString()
    & $PSScriptRoot\execute-NoUAC-shell.ps1 -codeStringToInject "pwsh -WorkingDirectory '$PSScriptRoot\shell\' -EncodedCommand $encodedCommand"
    $VMSwitches_out = Get-Content "$PSScriptRoot\shell\VMSwitches.PSSerialized"
    $VMSwitches =[System.Management.Automation.PSSerializer]::Deserialize($VMSwitches_out)
    $VMSwitches
}

# $VMSwitches = PSHyperVLabNet\Get-VMSwitch
# $VMSwitches
