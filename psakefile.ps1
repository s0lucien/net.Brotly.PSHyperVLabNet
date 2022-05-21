
task ensure-imported -Description "re-import PSHyperVLabNet" {
    Remove-Module PSHyperVLabNet -ErrorAction Continue
    Import-Module ".\PSHyperVLabNet.psd1"
}


task ensure-vswitches -description "Ensure virtual switches necessary to BrotlyNet are created" -depends ensure-imported {
    PSHyperVLabNet\New-VMSwitch -SwitchName "BrotlyNet_host" -SwitchType "Internal"
    PSHyperVLabNet\New-VMSwitch -SwitchName "BrotlyNet_pf2vm" -SwitchType "Private"
}


task book.surf_net_up -Description "Configure HyperV host (ltisurfbook)" -depends ensure-imported, ensure-vswitches {
    Write-Host "Will now configure book.surf HyperV host networking ..."
    PSHyperVLabNet\Install-InternalSwitch_HostStaticIP -SwitchName "BrotlyNet_host" -HostIP "10.10.80.57"
    PSHyperVLabNet\Install-InternalSwitch_HostFirewall -RuleName "BrotlyNet_host" -RuleLocalIP "10.10.80.57" -RuleRemoteAddress "10.10.80.0/24"
    PSHyperVLabNet\Install-OpenDHCP_Host -RuleLocalIP "10.10.80.57" -OpenDHCPRange "10.10.80.0-10.10.80.255"
    PSHyperVLabNet\AddToHosts -DesiredIP "10.10.80.57" -Hostname "book.surf"
}

task book.surf_net_down -Description "Removing HyperV host configuration (ltisurfbook)" -depends ensure-imported, remove-vswitches {
    Write-Host "Will now remove any HyperV host networking configurations from book.surf. Virtual switches will not be removed ..."
    PSHyperVLabNet\Uninstall-InternalSwitch_HostStaticIP -SwitchName "BrotlyNet_host"
    PSHyperVLabNet\Uninstall-InternalSwitch_HostFirewall -RuleName "BrotlyNet_host"
    PSHyperVLabNet\Uninstall-OpenDHCP_Host
    PSHyperVLabNet\RemoveFromHosts -DesiredIP -Hostname "book.surf"
}

### winfra

task winfra.surf_net_up -Description "Configure winfra guest (WinSrv2022)" -depends ensure-imported, ensure-vswitches {
    Write-Host "Will now configure winfra.surf HyperV guest networking ..."
    PSHyperVLabNet\PSHyperVLabNet\Add-VMNetworkAdapter -VMName "WinSrv2022" -SwitchName "BrotlyNet_host"
    PSHyperVLabNet\PSHyperVLabNet\Add-VMNetworkAdapter -VMName "WinSrv2022" -SwitchName "BrotlyNet_pf2vm"
    PSHyperVLabNet\Connect-VMNetworkAdapter -VMName "WinSrv2022" -SwitchName "BrotlyNet_host"
    PSHyperVLabNet\Connect-VMNetworkAdapter -VMName "WinSrv2022" -SwitchName "BrotlyNet_pf2vm"
    PSHyperVLabNet\Set-InternalSwitch_GuestDHCP_IP -VMName "WinSrv2022" -SwitchName "BrotlyNet_host" -IPAddress "10.10.80.143"
    PSHyperVLabNet\AddToHosts -DesiredIP "10.10.80.143" -Hostname "winfra.surf"
}


task winfra.surf_net_down -Description "Decomission winfra guest (WinSrv2022)" -depends ensure-imported {
    Write-Host "Will now remove winfra.surf HyperV guest networking ..."
    PSHyperVLabNet\Disconnect-VMNetworkAdapter -VMName "WinSrv2022" -SwitchName "BrotlyNet_host"
    PSHyperVLabNet\Disconnect-VMNetworkAdapter -VMName "WinSrv2022" -SwitchName "BrotlyNet_pf2vm"
    PSHyperVLabNet\PSHyperVLabNet\Remove-VMNetworkAdapter -VMName "WinSrv2022" -SwitchName "BrotlyNet_host"
    PSHyperVLabNet\PSHyperVLabNet\Remove-VMNetworkAdapter -VMName "WinSrv2022" -SwitchName "BrotlyNet_pf2vm"

    PSHyperVLabNet\Unset-InternalSwitch_GuestDHCP_IP -VMName "WinSrv2022" -SwitchName "BrotlyNet_host"
    PSHyperVLabNet\RemoveFromHosts -Hostname "winfra.surf"
}

task winfra.surf_vagrant_up -Description "Create winfra guest (WinSrv2022) from vagrant box" -depends ensure-imported {
    Write-Host "Will now create the winfra (WinSrv2022) HyperV guest as stated in the Vagrantfile ..."
    PSHyperVLabNet\Run-Vagrant_Up -ServerName "winfra"
    PSHyperVLabNet\Remove-AllVMNetworkAdapters -VMName "WinSrv2022"
}

task winfra.surf_vagrant_down -Description "Destroy winfra guest (WinSrv2022) using vagrant executable" -depends ensure-imported {
    Write-Host "Will now remove the winfra (WinSrv2022) HyperV guest VM files ..."
    PSHyperVLabNet\Run-Vagrant_Destroy -ServerName "winfra"
}

task winfra.surf_up -depends ensure-imported,  winfra.surf_vagrant_up, winfra.surf_net_up{
    PSHyperVLabNet\Start-VM "WinSrv2022"
}

task winfra.surf_turnoff -depends ensure-imported {
    PSHyperVLabNet\Stop-VM "WinSrv2022"
}

task winfra.surf_down -depends ensure-imported, winfra.surf_turnoff, winfra.surf_net_down, winfra.surf_vagrant_down

### raspberry

task raspberry.surf_net_up -Description "Configure raspberry guest (rpi)" -depends ensure-imported, ensure-vswitches {
    Write-Host "Will now configure raspberry.surf HyperV guest networking ..."
    PSHyperVLabNet\PSHyperVLabNet\Add-VMNetworkAdapter -VMName "rpi" -SwitchName "BrotlyNet_host"
    PSHyperVLabNet\PSHyperVLabNet\Add-VMNetworkAdapter -VMName "rpi" -SwitchName "BrotlyNet_pf2vm"
    PSHyperVLabNet\Connect-VMNetworkAdapter -VMName "rpi" -SwitchName "BrotlyNet_host"
    PSHyperVLabNet\Connect-VMNetworkAdapter -VMName "rpi" -SwitchName "BrotlyNet_pf2vm"
    PSHyperVLabNet\Set-InternalSwitch_GuestDHCP_IP -VMName "rpi" -SwitchName "BrotlyNet_host" -IPAddress "10.10.80.91"
    PSHyperVLabNet\AddToHosts -DesiredIP "10.10.80.91" -Hostname "raspberry.surf"
}

task raspberry.surf_net_down -Description "Decomission raspberry guest (rpi)" -depends ensure-imported {
    Write-Host "Will now remove raspberry.surf HyperV guest networking ..."
    PSHyperVLabNet\Disconnect-VMNetworkAdapter -VMName "rpi" -SwitchName "BrotlyNet_host"
    PSHyperVLabNet\Disconnect-VMNetworkAdapter -VMName "rpi" -SwitchName "BrotlyNet_pf2vm"
    PSHyperVLabNet\PSHyperVLabNet\Remove-VMNetworkAdapter -VMName "rpi" -SwitchName "BrotlyNet_host"
    PSHyperVLabNet\PSHyperVLabNet\Remove-VMNetworkAdapter -VMName "rpi" -SwitchName "BrotlyNet_pf2vm"

    PSHyperVLabNet\Unset-InternalSwitch_GuestDHCP_IP -VMName "rpi" -SwitchName "BrotlyNet_host"
    PSHyperVLabNet\RemoveFromHosts -Hostname "raspberry.surf"
}

### linfra

task linfra.surf_net_up -Description "Configure linfra guest (Ubuntu22.04)" -depends ensure-imported, ensure-vswitches {
    Write-Host "Will now configure linfra.surf HyperV guest networking ..."
    PSHyperVLabNet\PSHyperVLabNet\Add-VMNetworkAdapter -VMName "Ubuntu22.04" -SwitchName "BrotlyNet_host"
    PSHyperVLabNet\PSHyperVLabNet\Add-VMNetworkAdapter -VMName "Ubuntu22.04" -SwitchName "BrotlyNet_pf2vm"
    PSHyperVLabNet\Connect-VMNetworkAdapter -VMName "Ubuntu22.04" -SwitchName "BrotlyNet_host"
    PSHyperVLabNet\Connect-VMNetworkAdapter -VMName "Ubuntu22.04" -SwitchName "BrotlyNet_pf2vm"
    PSHyperVLabNet\Set-InternalSwitch_GuestDHCP_IP -VMName "Ubuntu22.04" -SwitchName "BrotlyNet_host" -IPAddress "10.10.80.141"
    PSHyperVLabNet\AddToHosts -DesiredIP "10.10.80.141" -Hostname "linfra.surf"
}

task linfra.surf_net_down -Description "Decomission linfra guest (Ubuntu22.04)" -depends ensure-imported {
    Write-Host "Will now remove linfra.surf HyperV guest networking ..."
    PSHyperVLabNet\Disconnect-VMNetworkAdapter -VMName "Ubuntu22.04" -SwitchName "BrotlyNet_host"
    PSHyperVLabNet\Disconnect-VMNetworkAdapter -VMName "Ubuntu22.04" -SwitchName "BrotlyNet_pf2vm"
    PSHyperVLabNet\PSHyperVLabNet\Remove-VMNetworkAdapter -VMName "Ubuntu22.04" -SwitchName "BrotlyNet_host"
    PSHyperVLabNet\PSHyperVLabNet\Remove-VMNetworkAdapter -VMName "Ubuntu22.04" -SwitchName "BrotlyNet_pf2vm"

    PSHyperVLabNet\Unset-InternalSwitch_GuestDHCP_IP -VMName "Ubuntu22.04" -SwitchName "BrotlyNet_host"
    PSHyperVLabNet\RemoveFromHosts -Hostname "linfra.surf"
}

task linfra.surf_vagrant_up -Description "Create linfra guest (Ubuntu22.04) from vagrant box" -depends ensure-imported {
    Write-Host "Will now create the linfra (Ubuntu22.04) HyperV guest as stated in the Vagrantfile ..."
    PSHyperVLabNet\Run-Vagrant_Up -ServerName "linfra"
    PSHyperVLabNet\Remove-AllVMNetworkAdapters -VMName "Ubuntu22.04"
}

task linfra.surf_vagrant_down -Description "Destroy linfra guest (Ubuntu22.04) using vagrant executable" -depends ensure-imported {
    Write-Host "Will now remove the linfra (Ubuntu22.04) HyperV guest VM files ..."
    PSHyperVLabNet\Run-Vagrant_Destroy -ServerName "linfra"
}

task linfra.surf_up -depends ensure-imported,  linfra.surf_vagrant_up, linfra.surf_net_up{
    PSHyperVLabNet\Start-VM "Ubuntu22.04"
}

task linfra.surf_turnoff -depends ensure-imported {
    PSHyperVLabNet\Stop-VM "Ubuntu22.04"
}

task linfra.surf_down -depends ensure-imported, linfra.surf_turnoff, linfra.surf_net_down, linfra.surf_vagrant_down

### hv

task hv.surf_net_up -Description "Configure hv guest (HyperVSrv2019)" -depends ensure-imported, ensure-vswitches {
    Write-Host "Will now configure hv.surf HyperV guest networking ..."
    PSHyperVLabNet\PSHyperVLabNet\Add-VMNetworkAdapter -VMName "HyperVSrv2019" -SwitchName "BrotlyNet_host"
    PSHyperVLabNet\PSHyperVLabNet\Add-VMNetworkAdapter -VMName "HyperVSrv2019" -SwitchName "BrotlyNet_pf2vm"
    PSHyperVLabNet\Connect-VMNetworkAdapter -VMName "HyperVSrv2019" -SwitchName "BrotlyNet_host"
    PSHyperVLabNet\Connect-VMNetworkAdapter -VMName "HyperVSrv2019" -SwitchName "BrotlyNet_pf2vm"
    PSHyperVLabNet\Set-InternalSwitch_GuestDHCP_IP -VMName "HyperVSrv2019" -SwitchName "BrotlyNet_host" -IPAddress "10.10.80.87"
    PSHyperVLabNet\AddToHosts -DesiredIP "10.10.80.87" -Hostname "hv.surf"
}

task hv.surf_net_down -Description "Decomission hv guest (HyperVSrv2019)" -depends ensure-imported {
    Write-Host "Will now remove hv.surf HyperV guest networking ..."
    PSHyperVLabNet\Disconnect-VMNetworkAdapter -VMName "HyperVSrv2019" -SwitchName "BrotlyNet_host"
    PSHyperVLabNet\Disconnect-VMNetworkAdapter -VMName "HyperVSrv2019" -SwitchName "BrotlyNet_pf2vm"
    PSHyperVLabNet\PSHyperVLabNet\Remove-VMNetworkAdapter -VMName "HyperVSrv2019" -SwitchName "BrotlyNet_host"
    PSHyperVLabNet\PSHyperVLabNet\Remove-VMNetworkAdapter -VMName "HyperVSrv2019" -SwitchName "BrotlyNet_pf2vm"

    PSHyperVLabNet\Unset-InternalSwitch_GuestDHCP_IP -VMName "HyperVSrv2019" -SwitchName "BrotlyNet_host"
    PSHyperVLabNet\RemoveFromHosts -Hostname "hv.surf"
}

task hv.surf_vagrant_up -Description "Create hv guest (HyperVSrv2019) from vagrant box" -depends ensure-imported {
    Write-Host "Will now create the hv (HyperVSrv2019) HyperV guest as stated in the Vagrantfile ..."
    PSHyperVLabNet\Run-Vagrant_Up -ServerName "hv"
    PSHyperVLabNet\Remove-AllVMNetworkAdapters -VMName "HyperVSrv2019"
}

task hv.surf_vagrant_down -Description "Destroy hv guest (HyperVSrv2019) using vagrant executable" -depends ensure-imported {
    Write-Host "Will now remove the hv (HyperVSrv2019) HyperV guest VM files ..."
    PSHyperVLabNet\Run-Vagrant_Destroy -ServerName "hv"
}

task hv.surf_up -depends ensure-imported,  hv.surf_vagrant_up, hv.surf_net_up{
    PSHyperVLabNet\Start-VM "HyperVSrv2019"
}

task hv.surf_turnoff -depends ensure-imported {
    PSHyperVLabNet\Stop-VM "HyperVSrv2019"
}

task hv.surf_down -depends ensure-imported, hv.surf_turnoff, hv.surf_net_down, hv.surf_vagrant_down

### pfs

task pfs.surf_net_up -Description "Configure pfs guest (pfSense)" -depends ensure-imported, ensure-vswitches {
    Write-Host "Will now configure pfs.surf HyperV guest networking ..."
    PSHyperVLabNet\PSHyperVLabNet\Add-VMNetworkAdapter -VMName "pfSense" -SwitchName "BrotlyNet_host"
    PSHyperVLabNet\PSHyperVLabNet\Add-VMNetworkAdapter -VMName "pfSense" -SwitchName "BrotlyNet_pf2vm"
    PSHyperVLabNet\PSHyperVLabNet\Add-VMNetworkAdapter -VMName "pfSense" -SwitchName "Default Switch"
    PSHyperVLabNet\Connect-VMNetworkAdapter -VMName "pfSense" -SwitchName "BrotlyNet_host"
    PSHyperVLabNet\Connect-VMNetworkAdapter -VMName "pfSense" -SwitchName "BrotlyNet_pf2vm"
    PSHyperVLabNet\Connect-VMNetworkAdapter -VMName "pfSense" -SwitchName "Default Switch"
    PSHyperVLabNet\Set-InternalSwitch_GuestDHCP_IP -VMName "pfSense" -SwitchName "BrotlyNet_host" -IPAddress "10.10.80.1"
    PSHyperVLabNet\AddToHosts -DesiredIP "10.10.80.1" -Hostname "pfs.surf"
}

task pfs.surf_net_down -Description "Decomission pfs guest (pfSense)" -depends ensure-imported {
    Write-Host "Will now remove pfs.surf HyperV guest networking ..."
    PSHyperVLabNet\Disconnect-VMNetworkAdapter -VMName "pfSense" -SwitchName "Default Switch"
    PSHyperVLabNet\Disconnect-VMNetworkAdapter -VMName "pfSense" -SwitchName "BrotlyNet_host"
    PSHyperVLabNet\Disconnect-VMNetworkAdapter -VMName "pfSense" -SwitchName "BrotlyNet_pf2vm"
    PSHyperVLabNet\PSHyperVLabNet\Remove-VMNetworkAdapter -VMName "pfSense" -SwitchName "Default Switch"
    PSHyperVLabNet\PSHyperVLabNet\Remove-VMNetworkAdapter -VMName "pfSense" -SwitchName "BrotlyNet_host"
    PSHyperVLabNet\PSHyperVLabNet\Remove-VMNetworkAdapter -VMName "pfSense" -SwitchName "BrotlyNet_pf2vm"

    PSHyperVLabNet\Unset-InternalSwitch_GuestDHCP_IP -VMName "pfSense" -SwitchName "BrotlyNet_host"
    PSHyperVLabNet\RemoveFromHosts -Hostname "pfs.surf"
}

task remove-vswitches -description "Remove all switches created for BrotlyNet" `
    -depends winfra.surf_net_down, raspberry.surf_net_down, linfra.surf_net_down, hv.surf_net_down, pfs.surf_net_down {
        PSHyperVLabNet\Remove-VMSwitch -SwitchName "BrotlyNet_host"
        PSHyperVLabNet\Remove-VMSwitch -SwitchName "BrotlyNet_pf2vm"
    }

task network_down -Description "Ensure PSHyperVLabNet (and SHELevate) are not present on the machine" -depends book.surf_net_down {
    Remove-Module PSHyperVLabNet -ErrorAction Continue
}

task network_up -Description "Set up networking for VMs in the lab" `
    -depends book.surf_net_up, pfs.surf_net_up, hv.surf_net_up, linfra.surf_net_up, winfra.surf_net_up, raspberry.surf_net_up

task test-cmd -depends ensure-imported {
    PSHyperVLabNet\Uninstall-InternalSwitch_HostFirewall -RuleName "BrotlyNet_host"
}