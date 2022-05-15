$RunVagrantDestroy_scriptBlockToInject = {
    $ServerName = $server_name

    vagrant destroy --force --no-tty $ServerName

    $ser = [System.Management.Automation.PSSerializer]::Serialize($?)
    $ser | Out-File "$(Get-Location)\VagrantDestroy.PSSerialized"
}

function PSHyperVLabNet\Run-Vagrant_Destroy($ServerName){
    
    $scriptBlockToInject = $RunVagrantDestroy_scriptBlockToInject.ToString() `
        -replace '\$server_name', "`"$ServerName`""
    $encodedCommand = Encode-Text-b64 -Text $scriptBlockToInject
    & $PSScriptRoot\execute-NoUAC-shell.ps1 -timeoutSec 120 -codeStringToInject "pwsh -WorkingDirectory '$PSScriptRoot\shell\' -EncodedCommand $encodedCommand"
    Write-Host "Executed. Retrieving result"
    $RestartOpenDHCPServer_out = Get-Content "$PSScriptRoot\shell\VagrantDestroy.PSSerialized"
    $SHElevate? =[System.Management.Automation.PSSerializer]::Deserialize($RestartOpenDHCPServer_out)
    $SHElevate?
}

# PSHyperVLabNet\Run-Vagrant_Destroy -ServerName "winfra"