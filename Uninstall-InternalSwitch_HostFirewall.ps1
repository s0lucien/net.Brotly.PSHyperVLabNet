. .\Encode-Text-b64.ps1

$UninstallInternalSwitchHostFirewall_scriptBlockToInject = {
    # unbox variables
    $RuleName= $rule_name

    if(Get-NetFirewallRule -Name "$RuleName`_inbound"){
        Write-Output "Removing $RuleName`_inbound ..."
        Remove-NetFirewallRule -Name "$RuleName`_inbound"
    }else{
        Write-Output "$RuleName`_inbound not found. Nothing to delete ..."
    }
    $ser = [System.Management.Automation.PSSerializer]::Serialize($?)
    $ser | Out-File "$(Get-Location)\Uninstall-InternalSwitch_HostFirewall.PSSerialized"
}

function PSHyperVLabNet\Uninstall-InternalSwitch_HostFirewall($RuleName){
    $scriptBlockToInject = $UninstallInternalSwitchHostFirewall_scriptBlockToInject.ToString() `
        -replace '\$rule_name', "`"$RuleName`""
    $encodedCommand = Encode-Text-b64 -Text $scriptBlockToInject
    & $PSScriptRoot\execute-NoUAC-shell.ps1 -codeStringToInject "pwsh -WorkingDirectory '$PSScriptRoot\shell\' -EncodedCommand $encodedCommand"
    Write-Host "Executed. Retrieving result"
    $InstallInternalSwitchHostFirewall_out = Get-Content "$PSScriptRoot\shell\Uninstall-InternalSwitch_HostFirewall.PSSerialized"
    $SHElevate? =[System.Management.Automation.PSSerializer]::Deserialize($InstallInternalSwitchHostFirewall_out)
    $SHElevate?
}

# PSHyperVLabNet\Unistall-InternalSwitch_HostFirewall -RuleName "BrotlyNet_host"
