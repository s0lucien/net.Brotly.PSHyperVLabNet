# https://social.technet.microsoft.com/Forums/windows/en-US/283936f1-ef43-4473-ba68-0564ffa0f772/how-to-create-a-vm-with-a-static-ip-assigned-to-it-using-powershell?forum=virtualmachingmgrhyperv

. .\Encode-Text-b64.ps1

$UninstallInternalSwitchHostStaticIp_scriptBlockToInject = {
    # unbox variable
    $SwitchName= $switch_name
    Write-Output "Removing static IP for 'vEthernet ($SwitchName)' ..."
    Get-NetIPAddress -InterfaceIndex (Get-NetAdapter -Name "vEthernet ($SwitchName)").ifIndex | Remove-NetIPAddress -confirm:$false
    $ser = [System.Management.Automation.PSSerializer]::Serialize($?)
    $ser | Out-File "$(Get-Location)\Uninstall-InternalSwitch_HostStaticIp.PSSerialized"
}

function PSHyperVLabNet\Uninstall-InternalSwitchHostStaticIP($SwitchName ){
    $scriptBlockToInject = $UninstallInternalSwitchHostStaticIp_scriptBlockToInject.ToString() `
        -replace '\$switch_name', "`"$SwitchName`""
    $encodedCommand = Encode-Text-b64 -Text $scriptBlockToInject
    & $PSScriptRoot\execute-NoUAC-shell.ps1 -codeStringToInject "pwsh -WorkingDirectory '$PSScriptRoot\shell\' -EncodedCommand $encodedCommand"
    Write-Host "Executed. Retrieving result"
    $InstallInternalSwitchHostStaticIp_out = Get-Content "$PSScriptRoot\shell\Uninstall-InternalSwitch_HostStaticIp.PSSerialized"
    $SHElevate? =[System.Management.Automation.PSSerializer]::Deserialize($InstallInternalSwitchHostStaticIp_out)
    $SHElevate?
}


# PSHyperVLabNet\Uninstall-InternalSwitch_HostStaticIP SwitchName "TEST INTERNAL"
