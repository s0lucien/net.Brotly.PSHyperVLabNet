# https://social.technet.microsoft.com/Forums/windows/en-US/283936f1-ef43-4473-ba68-0564ffa0f772/how-to-create-a-vm-with-a-static-ip-assigned-to-it-using-powershell?forum=virtualmachingmgrhyperv

# THIS DOES NOT WORK IN SHELEVATE
# . .\Encode-Text-b64.ps1
# . .\Get-MACAddressFromString.ps1
# . .\Set-VMNetworkConfiguration.ps1

# $InstallInternalSwitchGuestStaticIp_scriptBlockToInject = {
#     # unbox variable
#     $VMName = $vm_name
#     $MacAddress= $mac_address
#     $StaticIP = $static_ip
#     $SubnetMask = $subnet_mask
#     $SwitchName = $switch_name

#     Write-Host "Setting static IP on VM $VM for vSwitch $SwitchName with MAC Address $MacAddress running at location $(Get-Location) ..."
#     . "$(Get-Location)\..\Set-VMNetworkConfiguration.ps1"
#     $adapter = Get-VM -VMName $VMName | Get-VMNetworkAdapter  | Where-Object {$_.MacAddress -eq $MacAddress}
#     Write-Host "Adapter to be modified is $adapter"
#     Get-VM -VMName $VMName | Get-VMNetworkAdapter  | Where-Object {$_.MacAddress -eq $MacAddress} | PSHyperVLabNet\Set-VMNetworkConfiguration -IPAddress $StaticIP -Subnet $SubnetMask
#     $ser = [System.Management.Automation.PSSerializer]::Serialize($?)
#     $ser | Out-File "$(Get-Location)\Install-InternalSwitch_GuestStaticIp.PSSerialized"
# }

# function PSHyperVLabNet\Install-InternalSwitch_GuestStaticIP($SwitchName, $VMName, $StaticIP, $SubnetMask="255.255.255.0"){
#     $MacAddressWhereStaticIP = PSHyperVLabNet\Get-MACAddressFromString "$VMName-$SwitchName"
#     $scriptBlockToInject = $InstallInternalSwitchGuestStaticIp_scriptBlockToInject.ToString() `
#         -replace '\$switch_name', "`"$SwitchName`"" `
#         -replace '\$mac_address', "`"$MacAddressWhereStaticIP`"" `
#         -replace '\$static_ip', "`"$StaticIP`"" `
#         -replace '\$subnet_mask', "`"$SubnetMask`"" `
#         -replace '\$vm_name', "`"$VMName`""

#     $encodedCommand = Encode-Text-b64 -Text $scriptBlockToInject
#     & $PSScriptRoot\execute-NoUAC-shell.ps1 -codeStringToInject "pwsh -WorkingDirectory '$PSScriptRoot\shell\' -EncodedCommand $encodedCommand"
#     Write-Host "Executed. Retrieving result"
#     $InstallInternalSwitchHostStaticIp_out = Get-Content "$PSScriptRoot\shell\Install-InternalSwitch_GuestStaticIp.PSSerialized"
#     $SHElevate? =[System.Management.Automation.PSSerializer]::Deserialize($InstallInternalSwitchHostStaticIp_out)
#     $SHElevate?
# }


# PSHyperVLabNet\Install-InternalSwitch_GuestStaticIP -SwitchName "BrotlyNet_host" -VMName WinSrv2022 -StaticIp 10.10.80.143
#TODO: linux version
# PSHyperVLabNet\Install-InternalSwitch_GuestStaticIP -SwitchName "BrotlyNet_host" -VMName rpi -StaticIp 10.10.80.57
