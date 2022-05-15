$StopVM_scriptBlockToInject = {
    $VMName = $vm_name

    Stop-VM -VMName $VMName -Force -TurnOff

    $ser = [System.Management.Automation.PSSerializer]::Serialize($?)
    $ser | Out-File "$(Get-Location)\StopVM.PSSerialized"
}

function PSHyperVLabNet\Stop-VM($VMName){
    
    $scriptBlockToInject = $StopVM_scriptBlockToInject.ToString() `
        -replace '\$vm_name', "`"$VMName`""
    $encodedCommand = Encode-Text-b64 -Text $scriptBlockToInject
    & $PSScriptRoot\execute-NoUAC-shell.ps1 -codeStringToInject "pwsh -WorkingDirectory '$PSScriptRoot\shell\' -EncodedCommand $encodedCommand"
    Write-Host "Executed. Retrieving result"
    $StopVM_out = Get-Content "$PSScriptRoot\shell\StopVM.PSSerialized"
    $SHElevate? =[System.Management.Automation.PSSerializer]::Deserialize($StopVM_out)
    $SHElevate?
}

# PSHyperVLabNet\Stop-VM -VMName "pfsense"