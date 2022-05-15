$RunVagrantUp_scriptBlockToInject = {
    $ServerName = $server_name

    vagrant up --no-tty --no-provision --provider hyperv $ServerName

    $ser = [System.Management.Automation.PSSerializer]::Serialize($?)
    $ser | Out-File "$(Get-Location)\VagrantUp.PSSerialized"
}

function PSHyperVLabNet\Run-Vagrant_Up($ServerName){
    
    $scriptBlockToInject = $RunVagrantUp_scriptBlockToInject.ToString() `
        -replace '\$server_name', "`"$ServerName`""
    $encodedCommand = Encode-Text-b64 -Text $scriptBlockToInject
    & $PSScriptRoot\execute-NoUAC-shell.ps1 -timeoutSec 300 -codeStringToInject "pwsh -WorkingDirectory '$PSScriptRoot\shell\' -EncodedCommand $encodedCommand"
    Write-Host "Executed. Retrieving result"
    $RunVagrantUp_out = Get-Content "$PSScriptRoot\shell\VagrantUp.PSSerialized"
    $SHElevate? =[System.Management.Automation.PSSerializer]::Deserialize($RunVagrantUp_out)
    $SHElevate?
}

# PSHyperVLabNet\Run-Vagrant_Up -ServerName "linfra"