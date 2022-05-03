# https://social.technet.microsoft.com/Forums/windows/en-US/283936f1-ef43-4473-ba68-0564ffa0f772/how-to-create-a-vm-with-a-static-ip-assigned-to-it-using-powershell?forum=virtualmachingmgrhyperv

# Get-NetIPAddress -InterfaceIndex (Get-NetAdapter -Name 'vEthernet (BrotlyNet_host)').ifIndex | Remove-NetIPAddress -confirm:$false
# New-NetIPAddress -InterfaceAlias 'vEthernet (BrotlyNet_host)' -IPAddress '10.10.80.57' -PrefixLength 24
# Set-DnsClientServerAddress -InterfaceAlias 'vEthernet (BrotlyNet_host)' -ServerAddresses ("1.1.1.1","9.9.9.9")
. .\Encode-Text-b64.ps1

$InstallInternalSwitchHostStaticIp_scriptBlockToInject = {
    # unbox variables
    $SwitchName= $switch_name
    $HostIP = $host_ip
    Write-Output "Setting IP to $HostIP for 'vEthernet ($SwitchName)' ..."
    Get-NetIPAddress -InterfaceIndex (Get-NetAdapter -Name "vEthernet ($SwitchName)").ifIndex | Remove-NetIPAddress -confirm:$false
    New-NetIPAddress -InterfaceAlias "vEthernet ($SwitchName)" -IPAddress $HostIP -PrefixLength 24
    $ser = [System.Management.Automation.PSSerializer]::Serialize($?)
    $ser | Out-File "$(Get-Location)\Install-InternalSwitchHostStaticIp.PSSerialized"
}

function PSHyperVLabNet\Install-InternalSwitchHostStaticIP($SwitchName, $HostIP){
    $scriptBlockToInject = $InstallInternalSwitchHostStaticIp_scriptBlockToInject.ToString() `
        -replace '\$switch_name', "`"$SwitchName`"" `
        -replace '\$host_ip', "`"$HostIP`""
    $encodedCommand = Encode-Text-b64 -Text $scriptBlockToInject
    & $PSScriptRoot\execute-NoUAC-shell.ps1 -codeStringToInject "pwsh -WorkingDirectory '$PSScriptRoot\shell\' -EncodedCommand $encodedCommand"
    Write-Host "Executed. Retrieving result"
    $InstallInternalSwitchHostStaticIp_out = Get-Content "$PSScriptRoot\shell\Install-InternalSwitchHostStaticIp.PSSerialized"
    $SHElevate? =[System.Management.Automation.PSSerializer]::Deserialize($InstallInternalSwitchHostStaticIp_out)
    $SHElevate?
}

# PSHyperVLabNet\Install-InternalSwitchHostStaticIP -SwitchName "TEST INTERNAL" -HostIP "10.10.80.58"

