. .\Encode-ScriptBlock-b64.ps1

$GetVM_scriptBlockToInject = {
    $VMs = Get-VM -Verbose
    $ser = [System.Management.Automation.PSSerializer]::Serialize($VMs)
    Write-Host "Writing VMs to file $(Get-Location)\VMs.PSSerialized"
    $ser | Out-File "$(Get-Location)\VMs.PSSerialized"
    $VMs
}

function PSHyperVLabNet\Get-VM {
    $encodedCommand = Encode-ScriptBlock-b64 -ScriptBlockToEncode $GetVM_scriptBlockToInject
    & $PSScriptRoot\execute-NoUAC-shell.ps1 -codeStringToInject "pwsh -WorkingDirectory '$PSScriptRoot\shell\' -EncodedCommand $encodedCommand"
    Write-Host "Executed. Retrieving result"
    $VMs_out = Get-Content "$PSScriptRoot\shell\VMs.PSSerialized"
    $VMs =[System.Management.Automation.PSSerializer]::Deserialize($VMs_out)
    $VMs
}

# $VMs = PSHyperVLabNet\Get-VM
# $VMs
