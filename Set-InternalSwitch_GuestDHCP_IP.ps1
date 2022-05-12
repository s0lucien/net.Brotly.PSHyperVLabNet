$RestartOpenDHCPServer_scriptBlockToInject = {
    Restart-Service OpenDHCPServer

    $ser = [System.Management.Automation.PSSerializer]::Serialize($?)
    $ser | Out-File "$(Get-Location)\RestartOpenDHCPServer.PSSerialized"
}

function PSHyperVLabNet\Set-InternalSwitch_GuestDHCP_IP($VMName, $SwitchName, $IPAddress){
    
    Import-Module PsIni
    $OldINIContent = Get-IniContent "$PSScriptRoot\dhcp\OpenDHCPServer.ini"

    $mac = ((PSHyperVLabNet\Get-MACAddressFromString "$VMName-$SwitchName") -split '(.{2})' -ne '') -join ':'
    Write-Host "MAC address $mac will be assigned IP address $IPAddress"
    $ip = @{"IP"=$IPAddress}

    $OldINIContent[$mac]=$ip

    Out-IniFile -InputObject $OldINIContent -Force -FilePath "$PSScriptRoot\dhcp\OpenDHCPServer.ini"

    $scriptBlockToInject = $RestartOpenDHCPServer_scriptBlockToInject.ToString()
    $encodedCommand = Encode-Text-b64 -Text $scriptBlockToInject
    & $PSScriptRoot\execute-NoUAC-shell.ps1 -codeStringToInject "pwsh -WorkingDirectory '$PSScriptRoot\shell\' -EncodedCommand $encodedCommand"
    Write-Host "Executed. Retrieving result"
    $RestartOpenDHCPServer_out = Get-Content "$PSScriptRoot\shell\RestartOpenDHCPServer.PSSerialized"
    $SHElevate? =[System.Management.Automation.PSSerializer]::Deserialize($RestartOpenDHCPServer_out)
    $SHElevate?
}

# PSHyperVLabNet\Set-InternalSwitch_GuestDHCP_IP -VMName "rpi" -SwitchName "BrotlyNet_host" -IPAddress "10.10.80.91"



