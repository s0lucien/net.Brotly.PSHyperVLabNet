. .\Encode-Text-b64.ps1

$InstallOpenDHCPHost_scriptBlockToInject = {
    if(-not (Get-NetFirewallRule -Name "OpenDHCP" -ErrorAction Continue)){
        Write-Output "Allowing opendhcpserver.exe to respond to ARP packets ' ..."
        New-NetFirewallRule -DisplayName "OpenDHCP server allow inbound connections" -Name "OpenDHCP" -Enabled "True" -profile "Any" `
            -Action "Allow" -Program "$(Get-Location)\..\dhcp\OpenDHCPServer.exe" `
            -Direction Inbound -Protocol UDP -RemotePort 68 -LocalPort 67
    }else{
        Write-Output "Firewall rule 'OpenDHCP' found. Nothing to do ..."
    }

    if(-not (Get-Service -Name "OpenDHCPServer")){
        Write-Output "Creating service for OpenDHCPServer.exe because it does not exist"
        sc create OpenDHCPServer binPath="$(Get-Location)\..\dhcp\OpenDHCPServer.exe" displayName= "Open DHCP Server"
        sc start OpenDHCPServer
        
    }else{
        Write-Output "OpenDHCPServer service already exists. Making sure it is started ..."
        sc start OpenDHCPServer
    }

    $ser = [System.Management.Automation.PSSerializer]::Serialize($?)
    $ser | Out-File "$(Get-Location)\Install-OpenDHCP_Host.PSSerialized"
}

function PSHyperVLabNet\Install-OpenDHCP_Host($RuleLocalIP, $OpenDHCPRange){
    Import-Module PsIni
    $listen_on = @{""=$RuleLocalIP}
    $logging = @{"LogLevel"="All"}
    $range_set = @{"DHCPRange"=$OpenDHCPRange}

    $NewINIContent = @{
        "LOGGING"=$logging;
        "LISTEN_ON"=$listen_on;
        "RANGE_SET"=$range_set;
    }

    Out-IniFile -InputObject $NewINIContent -Force -FilePath "$PSScriptRoot\dhcp\OpenDHCPServer.ini"

    $scriptBlockToInject = $InstallOpenDHCPHost_scriptBlockToInject.ToString()
    $encodedCommand = Encode-Text-b64 -Text $scriptBlockToInject
    & $PSScriptRoot\execute-NoUAC-shell.ps1 -codeStringToInject "pwsh -WorkingDirectory '$PSScriptRoot\shell\' -EncodedCommand $encodedCommand"
    Write-Host "Executed. Retrieving result"
    $InstallInternalSwitchHostStaticIp_out = Get-Content "$PSScriptRoot\shell\Install-OpenDHCP_Host.PSSerialized"
    $SHElevate? =[System.Management.Automation.PSSerializer]::Deserialize($InstallInternalSwitchHostStaticIp_out)
    $SHElevate?
}

# PSHyperVLabNet\Install-OpenDHCP_Host -RuleLocalIP "10.10.80.57" -OpenDHCPRange "10.10.80.0-10.10.80.255"

