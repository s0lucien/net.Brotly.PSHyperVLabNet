
task ensure-imported -Description "re-import PSHyperVLabNet" {
    Remove-Module PSHyperVLabNet -ErrorAction Continue
    Import-Module ".\PSHyperVLabNet.psd1"
}

task ensure-removed -Description "Ensure PSHyperVLabNet (and SHELevate) are not present on the machine" -depends remove-vswitches {
    Remove-Module PSHyperVLabNet -ErrorAction Continue
}

task ensure-vswitches -description "Ensure virtual switches necessary to BrotlyNet are created" -depends ensure-imported {
    PSHyperVLabNet\New-VMSwitch -SwitchName "vagrant_dummy" -SwitchType "Internal"
    PSHyperVLabNet\New-VMSwitch -SwitchName "BrotlyNet_host" -SwitchType "Internal"
    PSHyperVLabNet\New-VMSwitch -SwitchName "BrotlyNet_pf2vm" -SwitchType "Private"
}

task remove-vswitches -description "Remove all switches created for BrotlyNet" `
    -depends winfra.surf_down, raspberry.surf_down, linfra.surf_down, hv.surf_down, pfs.surf_down {
        PSHyperVLabNet\Remove-VMSwitch -SwitchName "vagrant_dummy"
        PSHyperVLabNet\Remove-VMSwitch -SwitchName "BrotlyNet_host"
        PSHyperVLabNet\Remove-VMSwitch -SwitchName "BrotlyNet_pf2vm"
    }

task book.surf_up -Description "Configure HyperV host (ltisurfbook)" -depends ensure-imported, ensure-vswitches {
    Write-Host "Will now configure book.surf HyperV host networking ..."
    PSHyperVLabNet\Install-InternalSwitch_HostStaticIP -SwitchName "BrotlyNet_host" -HostIP "10.10.80.57"
    PSHyperVLabNet\Install-InternalSwitch_HostFirewall -RuleName "BrotlyNet_host" -RuleLocalIP "10.10.80.57" -RuleRemoteAddress "10.10.80.0/24"
    PSHyperVLabNet\Install-OpenDHCP_Host -RuleLocalIP "10.10.80.57" -OpenDHCPRange "10.10.80.0-10.10.80.255"
    PSHyperVLabNet\AddToHosts -DesiredIP "10.10.80.57" -Hostname "book.surf"
}

task book.surf_down -Description "Removing HyperV host configuration (ltisurfbook)" -depends ensure-imported, remove-vswitches {
    Write-Host "Will now remove any HyperV host networking configurations from book.surf. Virtual switches will not be removed ..."
    PSHyperVLabNet\Uninstall-InternalSwitch_HostStaticIP -SwitchName "BrotlyNet_host"
    PSHyperVLabNet\Uninstall-InternalSwitch_HostFirewall -RuleName "BrotlyNet_host"
    PSHyperVLabNet\Uninstall-OpenDHCP_Host
    PSHyperVLabNet\RemoveFromHosts -DesiredIP -Hostname "book.surf"
}

task winfra.surf_up -Description "Configure winfra guest (WinSrv2022)" -depends ensure-imported, ensure-vswitches {
    Write-Host "Will now configure winfra.surf HyperV guest networking ..."
    PSHyperVLabNet\PSHyperVLabNet\Add-VMNetworkAdapter -VMName "WinSrv2022" -SwitchName "BrotlyNet_host"
    PSHyperVLabNet\Connect-VMNetworkAdapter -VMName "WinSrv2022" -SwitchName "BrotlyNet_host"
    PSHyperVLabNet\Set-InternalSwitch_GuestDHCP_IP -VMName "WinSrv2022" -SwitchName "BrotlyNet_host" -IPAddress "10.10.80.143"
    PSHyperVLabNet\AddToHosts -DesiredIP "10.10.80.143" -Hostname "winfra.surf"
}


task winfra.surf_down -Description "Decomission winfra guest (WinSrv2022)" -depends ensure-imported {
    Write-Host "Will now remove winfra.surf HyperV guest networking ..."
    PSHyperVLabNet\Disconnect-VMNetworkAdapter -VMName "WinSrv2022" -SwitchName "BrotlyNet_host"
    PSHyperVLabNet\Disconnect-VMNetworkAdapter -VMName "WinSrv2022" -SwitchName "BrotlyNet_pf2vm"
    PSHyperVLabNet\PSHyperVLabNet\Remove-VMNetworkAdapter -VMName "WinSrv2022" -SwitchName "BrotlyNet_host"
    PSHyperVLabNet\PSHyperVLabNet\Remove-VMNetworkAdapter -VMName "WinSrv2022" -SwitchName "BrotlyNet_pf2vm"

    PSHyperVLabNet\Unset-InternalSwitch_GuestDHCP_IP -VMName "WinSrv2022" -SwitchName "BrotlyNet_host"
    PSHyperVLabNet\RemoveFromHosts -Hostname "winfra.surf"
}

task raspberry.surf_up -Description "Configure raspberry guest (rpi)" -depends ensure-imported, ensure-vswitches {
    Write-Host "Will now configure raspberry.surf HyperV guest networking ..."
    PSHyperVLabNet\PSHyperVLabNet\Add-VMNetworkAdapter -VMName "rpi" -SwitchName "BrotlyNet_host"
    PSHyperVLabNet\PSHyperVLabNet\Add-VMNetworkAdapter -VMName "rpi" -SwitchName "BrotlyNet_pf2vm"
    PSHyperVLabNet\Connect-VMNetworkAdapter -VMName "rpi" -SwitchName "BrotlyNet_host"
    PSHyperVLabNet\Connect-VMNetworkAdapter -VMName "rpi" -SwitchName "BrotlyNet_pf2vm"
    PSHyperVLabNet\Set-InternalSwitch_GuestDHCP_IP -VMName "rpi" -SwitchName "BrotlyNet_host" -IPAddress "10.10.80.91"
    PSHyperVLabNet\AddToHosts -DesiredIP "10.10.80.91" -Hostname "raspberry.surf"
}

task raspberry.surf_down -Description "Decomission raspberry guest (rpi)" -depends ensure-imported {
    Write-Host "Will now remove raspberry.surf HyperV guest networking ..."
    PSHyperVLabNet\Disconnect-VMNetworkAdapter -VMName "rpi" -SwitchName "BrotlyNet_host"
    PSHyperVLabNet\Disconnect-VMNetworkAdapter -VMName "rpi" -SwitchName "BrotlyNet_pf2vm"
    PSHyperVLabNet\PSHyperVLabNet\Remove-VMNetworkAdapter -VMName "rpi" -SwitchName "BrotlyNet_host"
    PSHyperVLabNet\PSHyperVLabNet\Remove-VMNetworkAdapter -VMName "rpi" -SwitchName "BrotlyNet_pf2vm"

    PSHyperVLabNet\Unset-InternalSwitch_GuestDHCP_IP -VMName "rpi" -SwitchName "BrotlyNet_host"
    PSHyperVLabNet\RemoveFromHosts -Hostname "raspberry.surf"
}

task linfra.surf_up -Description "Configure linfra guest (Ubuntu22.04)" -depends ensure-imported, ensure-vswitches {
    Write-Host "Will now configure linfra.surf HyperV guest networking ..."
    PSHyperVLabNet\PSHyperVLabNet\Add-VMNetworkAdapter -VMName "Ubuntu22.04" -SwitchName "BrotlyNet_host"
    PSHyperVLabNet\PSHyperVLabNet\Add-VMNetworkAdapter -VMName "Ubuntu22.04" -SwitchName "BrotlyNet_pf2vm"
    PSHyperVLabNet\Connect-VMNetworkAdapter -VMName "Ubuntu22.04" -SwitchName "BrotlyNet_host"
    PSHyperVLabNet\Connect-VMNetworkAdapter -VMName "Ubuntu22.04" -SwitchName "BrotlyNet_pf2vm"
    PSHyperVLabNet\Set-InternalSwitch_GuestDHCP_IP -VMName "Ubuntu22.04" -SwitchName "BrotlyNet_host" -IPAddress "10.10.80.141"
    PSHyperVLabNet\AddToHosts -DesiredIP "10.10.80.141" -Hostname "linfra.surf"
}

task linfra.surf_down -Description "Decomission linfra guest (Ubuntu22.04)" -depends ensure-imported {
    Write-Host "Will now remove linfra.surf HyperV guest networking ..."
    PSHyperVLabNet\Disconnect-VMNetworkAdapter -VMName "Ubuntu22.04" -SwitchName "BrotlyNet_host"
    PSHyperVLabNet\Disconnect-VMNetworkAdapter -VMName "Ubuntu22.04" -SwitchName "BrotlyNet_pf2vm"
    PSHyperVLabNet\PSHyperVLabNet\Remove-VMNetworkAdapter -VMName "Ubuntu22.04" -SwitchName "BrotlyNet_host"
    PSHyperVLabNet\PSHyperVLabNet\Remove-VMNetworkAdapter -VMName "Ubuntu22.04" -SwitchName "BrotlyNet_pf2vm"

    PSHyperVLabNet\Unset-InternalSwitch_GuestDHCP_IP -VMName "Ubuntu22.04" -SwitchName "BrotlyNet_host"
    PSHyperVLabNet\RemoveFromHosts -Hostname "linfra.surf"
}

task hv.surf_up -Description "Configure hv guest (HyperVSrv2019)" -depends ensure-imported, ensure-vswitches {
    Write-Host "Will now configure hv.surf HyperV guest networking ..."
    PSHyperVLabNet\PSHyperVLabNet\Add-VMNetworkAdapter -VMName "HyperVSrv2019" -SwitchName "BrotlyNet_host"
    PSHyperVLabNet\PSHyperVLabNet\Add-VMNetworkAdapter -VMName "HyperVSrv2019" -SwitchName "BrotlyNet_pf2vm"
    PSHyperVLabNet\Connect-VMNetworkAdapter -VMName "HyperVSrv2019" -SwitchName "BrotlyNet_host"
    PSHyperVLabNet\Connect-VMNetworkAdapter -VMName "HyperVSrv2019" -SwitchName "BrotlyNet_pf2vm"
    PSHyperVLabNet\Set-InternalSwitch_GuestDHCP_IP -VMName "HyperVSrv2019" -SwitchName "BrotlyNet_host" -IPAddress "10.10.80.87"
    PSHyperVLabNet\AddToHosts -DesiredIP "10.10.80.87" -Hostname "hv.surf"
}

task hv.surf_down -Description "Decomission hv guest (HyperVSrv2019)" -depends ensure-imported {
    Write-Host "Will now remove hv.surf HyperV guest networking ..."
    PSHyperVLabNet\Disconnect-VMNetworkAdapter -VMName "HyperVSrv2019" -SwitchName "BrotlyNet_host"
    PSHyperVLabNet\Disconnect-VMNetworkAdapter -VMName "HyperVSrv2019" -SwitchName "BrotlyNet_pf2vm"
    PSHyperVLabNet\PSHyperVLabNet\Remove-VMNetworkAdapter -VMName "HyperVSrv2019" -SwitchName "BrotlyNet_host"
    PSHyperVLabNet\PSHyperVLabNet\Remove-VMNetworkAdapter -VMName "HyperVSrv2019" -SwitchName "BrotlyNet_pf2vm"

    PSHyperVLabNet\Unset-InternalSwitch_GuestDHCP_IP -VMName "HyperVSrv2019" -SwitchName "BrotlyNet_host"
    PSHyperVLabNet\RemoveFromHosts -Hostname "hv.surf"
}

task pfs.surf_up -Description "Configure pf guest (pfSense)" -depends ensure-imported, ensure-vswitches {
    Write-Host "Will now configure pfsense.surf HyperV guest networking ..."
    PSHyperVLabNet\PSHyperVLabNet\Add-VMNetworkAdapter -VMName "pfSense" -SwitchName "BrotlyNet_host"
    PSHyperVLabNet\PSHyperVLabNet\Add-VMNetworkAdapter -VMName "pfSense" -SwitchName "BrotlyNet_pf2vm"
    PSHyperVLabNet\PSHyperVLabNet\Add-VMNetworkAdapter -VMName "pfSense" -SwitchName "Default Switch"
    PSHyperVLabNet\Connect-VMNetworkAdapter -VMName "pfSense" -SwitchName "BrotlyNet_host"
    PSHyperVLabNet\Connect-VMNetworkAdapter -VMName "pfSense" -SwitchName "BrotlyNet_pf2vm"
    PSHyperVLabNet\Connect-VMNetworkAdapter -VMName "pfSense" -SwitchName "Default Switch"
    PSHyperVLabNet\Set-InternalSwitch_GuestDHCP_IP -VMName "pfSense" -SwitchName "BrotlyNet_host" -IPAddress "10.10.80.1"
    PSHyperVLabNet\AddToHosts -DesiredIP "10.10.80.1" -Hostname "pfsense.surf"
}

task pfs.surf_down -Description "Decomission pfs guest (pfSense)" -depends ensure-imported {
    Write-Host "Will now remove pfsense.surf HyperV guest networking ..."
    PSHyperVLabNet\Disconnect-VMNetworkAdapter -VMName "pfSense" -SwitchName "Default Switch"
    PSHyperVLabNet\Disconnect-VMNetworkAdapter -VMName "pfSense" -SwitchName "BrotlyNet_host"
    PSHyperVLabNet\Disconnect-VMNetworkAdapter -VMName "pfSense" -SwitchName "BrotlyNet_pf2vm"
    PSHyperVLabNet\PSHyperVLabNet\Remove-VMNetworkAdapter -VMName "pfSense" -SwitchName "Default Switch"
    PSHyperVLabNet\PSHyperVLabNet\Remove-VMNetworkAdapter -VMName "pfSense" -SwitchName "BrotlyNet_host"
    PSHyperVLabNet\PSHyperVLabNet\Remove-VMNetworkAdapter -VMName "pfSense" -SwitchName "BrotlyNet_pf2vm"

    PSHyperVLabNet\Unset-InternalSwitch_GuestDHCP_IP -VMName "pfSense" -SwitchName "BrotlyNet_host"
    PSHyperVLabNet\RemoveFromHosts -Hostname "pfs.surf"
}

task test-cmd -depends ensure-imported {
    PSHyperVLabNet\Uninstall-InternalSwitch_HostFirewall -RuleName "BrotlyNet_host"
}