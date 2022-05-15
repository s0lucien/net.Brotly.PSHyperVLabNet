$StartVM_scriptBlockToInject = {
    $VMName = $vm_name

    Start-VM -VMName $VMName

    $ser = [System.Management.Automation.PSSerializer]::Serialize($?)
    $ser | Out-File "$(Get-Location)\StartVM.PSSerialized"
}

function PSHyperVLabNet\Start-VM($VMName){
    
    $scriptBlockToInject = $StartVM_scriptBlockToInject.ToString() `
        -replace '\$vm_name', "`"$VMName`""
    $encodedCommand = Encode-Text-b64 -Text $scriptBlockToInject
    & $PSScriptRoot\execute-NoUAC-shell.ps1 -codeStringToInject "pwsh -WorkingDirectory '$PSScriptRoot\shell\' -EncodedCommand $encodedCommand"
    Write-Host "Executed. Retrieving result"
    $StartVM_out = Get-Content "$PSScriptRoot\shell\StartVM.PSSerialized"
    $SHElevate? =[System.Management.Automation.PSSerializer]::Deserialize($StartVM_out)
    $SHElevate?
}

# PSHyperVLabNet\Start-VM -VMName "pfsense"