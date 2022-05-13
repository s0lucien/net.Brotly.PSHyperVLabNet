$UnsetMacRestartOpenDHCPServer_scriptBlockToInject = {
    Restart-Service OpenDHCPServer

    $ser = [System.Management.Automation.PSSerializer]::Serialize($?)
    $ser | Out-File "$(Get-Location)\UnsetMacRestartOpenDHCPServer.PSSerialized"
}

function PSHyperVLabNet\Unset-InternalSwitch_GuestDHCP_IP($VMName, $SwitchName){
    
    Import-Module PsIni
    $OldINIContent = Get-IniContent "$PSScriptRoot\dhcp\OpenDHCPServer.ini"

    $mac = ((PSHyperVLabNet\Get-MACAddressFromString "$VMName-$SwitchName") -split '(.{2})' -ne '') -join ':'
    Write-Host "MAC address $mac will be unassigned from OpenDHCP managed addresses"

    $OldINIContent.remove($mac)

    Out-IniFile -InputObject $OldINIContent -Force -FilePath "$PSScriptRoot\dhcp\OpenDHCPServer.ini"

    $scriptBlockToInject = $UnsetMacRestartOpenDHCPServer_scriptBlockToInject.ToString()
    $encodedCommand = Encode-Text-b64 -Text $scriptBlockToInject
    & $PSScriptRoot\execute-NoUAC-shell.ps1 -codeStringToInject "pwsh -WorkingDirectory '$PSScriptRoot\shell\' -EncodedCommand $encodedCommand"
    Write-Host "Executed. Retrieving result"
    $RestartOpenDHCPServer_out = Get-Content "$PSScriptRoot\shell\UnsetMacRestartOpenDHCPServer.PSSerialized"
    $SHElevate? =[System.Management.Automation.PSSerializer]::Deserialize($RestartOpenDHCPServer_out)
    $SHElevate?
}

# PSHyperVLabNet\Unset-InternalSwitch_GuestDHCP_IP -VMName "rpi" -SwitchName "BrotlyNet_host"



