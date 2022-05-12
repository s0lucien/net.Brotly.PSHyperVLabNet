. .\Encode-Text-b64.ps1

$UninstallOpenDHCPHost_scriptBlockToInject = {
    if(Get-NetFirewallRule -Name "OpenDHCP" -ErrorAction Continue){
        Write-Output "Removing Firewall rule for OpenDHCPServer.exe  ..."
        Remove-NetFirewallRule -Name "OpenDHCP"
    }else{
        Write-Output "Firewall rule 'OpenDHCP' not found. Nothing to remove ..."
    }

    if(Get-Service -Name "OpenDHCPServer" -ErrorAction Continue){
        Write-Output "Deleting service for OpenDHCPServer.exe"
        sc stop "OpenDHCPServer"
        sc delete "OpenDHCPServer"        
    }else{
        Write-Output "OpenDHCPServer service does not exist. Nothing to uninstall ..."
    }

    $ser = [System.Management.Automation.PSSerializer]::Serialize($?)
    $ser | Out-File "$(Get-Location)\Install-OpenDHCP_Host.PSSerialized"
}

function PSHyperVLabNet\Uninstall-OpenDHCP_Host{
    
    Remove-Item "$PSScriptRoot\dhcp\OpenDHCPServer.ini"
    $scriptBlockToInject = $UninstallOpenDHCPHost_scriptBlockToInject.ToString()
    $encodedCommand = Encode-Text-b64 -Text $scriptBlockToInject
    & $PSScriptRoot\execute-NoUAC-shell.ps1 -codeStringToInject "pwsh -WorkingDirectory '$PSScriptRoot\shell\' -EncodedCommand $encodedCommand"
    Write-Host "Executed. Retrieving result"
    $InstallInternalSwitchHostStaticIp_out = Get-Content "$PSScriptRoot\shell\Install-OpenDHCP_Host.PSSerialized"
    $SHElevate? =[System.Management.Automation.PSSerializer]::Deserialize($InstallInternalSwitchHostStaticIp_out)
    $SHElevate?
}

# PSHyperVLabNet\Uninstall-OpenDHCP_Host

