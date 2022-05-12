# https://social.technet.microsoft.com/Forums/windows/en-US/283936f1-ef43-4473-ba68-0564ffa0f772/how-to-create-a-vm-with-a-static-ip-assigned-to-it-using-powershell?forum=virtualmachingmgrhyperv

# Get-NetIPAddress -InterfaceIndex (Get-NetAdapter -Name 'vEthernet (BrotlyNet_host)').ifIndex | Remove-NetIPAddress -confirm:$false
# New-NetIPAddress -InterfaceAlias 'vEthernet (BrotlyNet_host)' -IPAddress '10.10.80.57' -PrefixLength 24
# Set-DnsClientServerAddress -InterfaceAlias 'vEthernet (BrotlyNet_host)' -ServerAddresses ("1.1.1.1","9.9.9.9")
. .\Encode-Text-b64.ps1

$InstallInternalSwitchHostFirewall_scriptBlockToInject = {
    # unbox variables
    $RuleName= $rule_name
    $RuleLocalIP = $rule_local_ip
    $RuleRemoteAddress = $rule_remote_address

    if(-not (Get-NetFirewallRule -Name "$RuleName`_inbound")){
        Write-Output "Allowing $RuleName`_inbound: $RuleRemoteAddress to connect to $RuleName Inbound ' ..."
        New-NetFirewallRule -DisplayName "Allow $RuleName Inbound" -Name "$RuleName`_Inbound" -Enabled "True" -profile "Any" `
            -LocalAddress $RuleLocalIP -Action "Allow" -Direction Inbound -RemoteAddress $RuleRemoteAddress
    }else{
        Write-Output "$RuleName`_inbound found. Nothing to do ..."
    }
    $ser = [System.Management.Automation.PSSerializer]::Serialize($?)
    $ser | Out-File "$(Get-Location)\Install-InternalSwitch_HostFirewall.PSSerialized"
}

function PSHyperVLabNet\Install-InternalSwitch_HostFirewall($RuleName, $RuleLocalIP, $RuleRemoteAddress ){
    $scriptBlockToInject = $InstallInternalSwitchHostFirewall_scriptBlockToInject.ToString() `
        -replace '\$rule_name', "`"$RuleName`"" `
        -replace '\$rule_local_address', "`"$RuleLocalIP`"" `
        -replace '\$rule_remote_address', "`"$RuleRemoteAddress`""
    $encodedCommand = Encode-Text-b64 -Text $scriptBlockToInject
    & $PSScriptRoot\execute-NoUAC-shell.ps1 -codeStringToInject "pwsh -WorkingDirectory '$PSScriptRoot\shell\' -EncodedCommand $encodedCommand"
    Write-Host "Executed. Retrieving result"
    $InstallInternalSwitchHostFirewall_out = Get-Content "$PSScriptRoot\shell\Install-InternalSwitch_HostFirewall.PSSerialized"
    $SHElevate? =[System.Management.Automation.PSSerializer]::Deserialize($InstallInternalSwitchHostFirewall_out)
    $SHElevate?
}

# PSHyperVLabNet\Install-InternalSwitch_HostFirewall -RuleName "BrotlyNet_host" -RuleLocalIP "10.10.80.57" -RuleRemoteAddress "10.10.80.0/24"
