
task ensure-imported -Description "re-import PSHyperVLabNet" {
    Remove-Module PSHyperVLabNet -ErrorAction Continue
    Import-Module ".\PSHyperVLabNet.psd1"
}

task ensure-removed -Description "Ensure PSHyperVLabNet (and SHELevate) are not present on the machine"  {
    Remove-Module PSHyperVLabNet -ErrorAction Continue
}


task book.surf_up -Description "Configure HyperV host (ltisurfbook)" -depends ensure-imported {
    Write-Host "Will now configure book.surf HyperV host networking ..."
    PSHyperVLabNet\New-VMSwitch -SwitchName "BrotlyNet_host" -SwitchType "Internal"
    PSHyperVLabNet\Install-InternalSwitch_HostStaticIP -SwitchName "BrotlyNet_host" -HostIP "10.10.80.57"
    PSHyperVLabNet\Install-InternalSwitch_HostFirewall -RuleName "BrotlyNet_host" -RuleLocalIP "10.10.80.57" -RuleRemoteAddress "10.10.80.0/24"
    PSHyperVLabNet\Install-OpenDHCP_Host -RuleLocalIP "10.10.80.57" -OpenDHCPRange "10.10.80.0-10.10.80.255"
    PSHyperVLabNet\AddToHosts -DesiredIP "10.10.80.57" -Hostname "book.surf"
}

task book.surf_down -Description "Removing HyperV host configuration (ltisurfbook)" -depends ensure-imported {
    Write-Host "Will now remove any HyperV host networking configurations from book.surf. Virtual switches will not be removed ..."
    PSHyperVLabNet\Uninstall-InternalSwitch_HostStaticIP -SwitchName "BrotlyNet_host"
    PSHyperVLabNet\Uninstall-InternalSwitch_HostFirewall -RuleName "BrotlyNet_host"
    PSHyperVLabNet\Uninstall-OpenDHCP_Host
    PSHyperVLabNet\RemoveFromHosts -DesiredIP -Hostname "book.surf"
}

task test-cmd -depends ensure-imported {
    PSHyperVLabNet\Uninstall-InternalSwitch_HostFirewall -RuleName "BrotlyNet_host"
}