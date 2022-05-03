function Setup-HyperVLabNet ($NetPrefix = "BrotlyNet") {

    ### Create vSwitches
    PSHyperVLabNet\New-VMSwitch -name "$($NetPrefix)_Private_pf2vm" -type "Private"
    PSHyperVLabNet\New-VMSwitch -name "$($NetPrefix)_Internal" -type "Internal"
    
    ### Create vNICs - SwitchName is necessary for the MAC address consistent hashing
    # raspberry MACs

    #IDEMPOTENT : remove before add to start from clean state
    PSHyperVLabNet\Remove-VMNetworkAdapter -VMName "rpi" -SwitchName "$($NetPrefix)_Internal"
    PSHyperVLabNet\Remove-VMNetworkAdapter -VMName "rpi" -SwitchName "$($NetPrefix)_Private_pf2vm"
    #END IDEMPOTENT
    PSHyperVLabNet\Add-VMNetworkAdapter -VMName "rpi" -SwitchName "$($NetPrefix)_Internal"
    PSHyperVLabNet\Add-VMNetworkAdapter -VMName "rpi" -SwitchName "$($NetPrefix)_Private_pf2vm"
    
    # winfra MACs
    #IDEMPOTENT : remove before add to start from clean state
    PSHyperVLabNet\Remove-VMNetworkAdapter -VMName "WinSrv2022" -SwitchName "$($NetPrefix)_Internal"
    PSHyperVLabNet\Remove-VMNetworkAdapter -VMName "WinSrv2022" -SwitchName "$($NetPrefix)_Private_pf2vm"
    #END IDEMPOTENT
    PSHyperVLabNet\Add-VMNetworkAdapter -VMName "WinSrv2022" -SwitchName "$($NetPrefix)_Internal"
    PSHyperVLabNet\Add-VMNetworkAdapter -VMName "WinSrv2022" -SwitchName "$($NetPrefix)_Private_pf2vm"

    # linfra MACs
    #IDEMPOTENT : remove before add to start from clean state
    PSHyperVLabNet\Remove-VMNetworkAdapter -VMName "Ubuntu22.04" -SwitchName "$($NetPrefix)_Internal"
    PSHyperVLabNet\Remove-VMNetworkAdapter -VMName "Ubuntu22.04" -SwitchName "$($NetPrefix)_Private_pf2vm"
    #END IDEMPOTENT
    PSHyperVLabNet\Add-VMNetworkAdapter -VMName "Ubuntu22.04" -SwitchName "$($NetPrefix)_Internal"
    PSHyperVLabNet\Add-VMNetworkAdapter -VMName "Ubuntu22.04" -SwitchName "$($NetPrefix)_Private_pf2vm"

    # hv MACs
    #IDEMPOTENT : remove before add to start from clean state
    PSHyperVLabNet\Remove-VMNetworkAdapter -VMName "HyperVSrv2019" -SwitchName "$($NetPrefix)_Internal"
    PSHyperVLabNet\Remove-VMNetworkAdapter -VMName "HyperVSrv2019" -SwitchName "$($NetPrefix)_Private_pf2vm"
    #END IDEMPOTENT
    PSHyperVLabNet\Add-VMNetworkAdapter -VMName "HyperVSrv2019" -SwitchName "$($NetPrefix)_Internal"
    PSHyperVLabNet\Add-VMNetworkAdapter -VMName "HyperVSrv2019" -SwitchName "$($NetPrefix)_Private_pf2vm"


    # pfsense MACs
    #IDEMPOTENT : remove before add to start from clean state
    PSHyperVLabNet\Remove-VMNetworkAdapter -VMName "pfSense" -SwitchName "$($NetPrefix)_Internal"
    PSHyperVLabNet\Remove-VMNetworkAdapter -VMName "pfSense" -SwitchName "$($NetPrefix)_Private_pf2vm"
    #END IDEMPOTENT
    PSHyperVLabNet\Add-VMNetworkAdapter -VMName "pfSense" -SwitchName "$($NetPrefix)_Internal"
    PSHyperVLabNet\Add-VMNetworkAdapter -VMName "pfSense" -SwitchName "$($NetPrefix)_Private_pf2vm"
    # share host internet connection using the NATed 'Default Switch'
    PSHyperVLabNet\Add-VMNetworkAdapter -VMName "pfSense" -SwitchName "Default Switch"


    ### Connect VMs to vSwitches
    # raspberry NICs
    # IDEMPOTENT: remove existing connections to the NIC Mac addresses to start from a clean state
    PSHyperVLabNet\Disconnect-VMNetworkAdapter -VMName "rpi" -SwitchName "$($NetPrefix)_Internal"
    PSHyperVLabNet\Disconnect-VMNetworkAdapter -VMName "rpi" -SwitchName "$($NetPrefix)_Private_pf2vm"
    # END IDEMPOTENT
    PSHyperVLabNet\Disconnect-VMNetworkAdapter -VMName "rpi" -SwitchName "$($NetPrefix)_Internal"
    PSHyperVLabNet\Disconnect-VMNetworkAdapter -VMName "rpi" -SwitchName "$($NetPrefix)_Private_pf2vm"

    # winfra NICs
    # IDEMPOTENT: remove existing connections to the NIC Mac addresses to start from a clean state
    PSHyperVLabNet\Disconnect-VMNetworkAdapter -VMName "WinSrv2022" -SwitchName "$($NetPrefix)_Internal"
    PSHyperVLabNet\Disconnect-VMNetworkAdapter -VMName "WinSrv2022" -SwitchName "$($NetPrefix)_Private_pf2vm"
    # END IDEMPOTENT    
    PSHyperVLabNet\Connect-VMNetworkAdapter -VMName "WinSrv2022" -SwitchName "$($NetPrefix)_Internal"
    PSHyperVLabNet\Connect-VMNetworkAdapter -VMName "WinSrv2022" -SwitchName "$($NetPrefix)_Private_pf2vm"

    # linfra NICs
    # IDEMPOTENT: remove existing connections to the NIC Mac addresses to start from a clean state
    PSHyperVLabNet\Disconnect-VMNetworkAdapter -VMName "Ubuntu22.04" -SwitchName "$($NetPrefix)_Internal"
    PSHyperVLabNet\Disconnect-VMNetworkAdapter -VMName "Ubuntu22.04" -SwitchName "$($NetPrefix)_Private_pf2vm"
    # END IDEMPOTENT    
    PSHyperVLabNet\Connect-VMNetworkAdapter -VMName "Ubuntu22.04" -SwitchName "$($NetPrefix)_Internal"
    PSHyperVLabNet\Connect-VMNetworkAdapter -VMName "Ubuntu22.04" -SwitchName "$($NetPrefix)_Private_pf2vm"

    # hv NICs
    # IDEMPOTENT: remove existing connections to the NIC Mac addresses to start from a clean state
    PSHyperVLabNet\Disconnect-VMNetworkAdapter -VMName "HyperVSrv2019" -SwitchName "$($NetPrefix)_Internal"
    PSHyperVLabNet\Disconnect-VMNetworkAdapter -VMName "HyperVSrv2019" -SwitchName "$($NetPrefix)_Private_pf2vm"
    # END IDEMPOTENT
    PSHyperVLabNet\Connect-VMNetworkAdapter -VMName "HyperVSrv2019" -SwitchName "$($NetPrefix)_Internal"
    PSHyperVLabNet\Connect-VMNetworkAdapter -VMName "HyperVSrv2019" -SwitchName "$($NetPrefix)_Private_pf2vm"

    # pfsense NICs
    # IDEMPOTENT: remove existing connections to the NIC Mac addresses to start from a clean state
    PSHyperVLabNet\Disconnect-VMNetworkAdapter -VMName "pfSense" -SwitchName "$($NetPrefix)_Internal"
    PSHyperVLabNet\Disconnect-VMNetworkAdapter -VMName "pfSense" -SwitchName "$($NetPrefix)_Private_pf2vm"
    # disconnect WAN vSwitch
    PSHyperVLabNet\Disconnect-VMNetworkAdapter -VMName "pfSense" -SwitchName "Default Switch"
    # END IDEMPOTENT
    PSHyperVLabNet\Connect-VMNetworkAdapter -VMName "pfSense" -SwitchName "$($NetPrefix)_Internal"
    PSHyperVLabNet\Connect-VMNetworkAdapter -VMName "pfSense" -SwitchName "$($NetPrefix)_Private_pf2vm"
    # connect to internet using the NATed 'Default Switch'
    PSHyperVLabNet\Connect-VMNetworkAdapter -VMName "pfSense" -SwitchName "Default Switch"

    ### Static IPs
    ## for the host (book.surf)
    Get-NetIPAddress -InterfaceIndex (Get-NetAdapter -Name "vEthernet ($($NetPrefix)_Internal)").ifIndex | Remove-NetIPAddress -confirm:$false
    New-NetIPAddress -InterfaceAlias "vEthernet ($($NetPrefix)_Internal)" -IPAddress "10.10.80.57" -PrefixLength 24
    ## for the VMs
    . $PSScriptRoot\..\Set-VMNetworkConfiguration.ps1
    . $PSScriptRoot\..\Get-MACAddressFromString.ps1
    . $PSScriptRoot\..\EditHosts.ps1

    # for pfsense (pf.surf)
    $VMName="pfsense"
    $ipAddress = "10.10.80.1"
    $hostName="pf.surf"
    $MacAddressWhereStaticIP = PSHyperVLabNet\Get-MACAddressFromString "$VMName-BrotlyNet_Internal"
    Get-VM -VMName $VMName | Get-VMNetworkAdapter  | Where-Object {$_.MacAddress -eq $MacAddressWhereStaticIP} | PSHyperVLabNet\Set-VMNetworkConfiguration -IPAddress $ipAddress -Subnet "255.255.255.0"   
    PSHyperVLabNet\RemoveFromHosts -Hostname $hostName
    PSHyperVLabNet\AddToHosts -Hostname $hostName -DesiredIp $ipAddress
    
    # for rpi (rpi.surf)
    $VMName="rpi"
    $ipAddress = "10.10.80.91"
    $hostName="rpi.surf"
    $MacAddressWhereStaticIP = PSHyperVLabNet\Get-MACAddressFromString "$VMName-BrotlyNet_Internal"
    Get-VM -VMName $VMName | Get-VMNetworkAdapter  | Where-Object {$_.MacAddress -eq $MacAddressWhereStaticIP} | PSHyperVLabNet\Set-VMNetworkConfiguration -IPAddress $ipAddress -Subnet "255.255.255.0"
    PSHyperVLabNet\RemoveFromHosts -Hostname $hostName
    PSHyperVLabNet\AddToHosts -Hostname $hostName -DesiredIp $ipAddress

    # for WinSrv2022 (winfra.surf)
    $VMName="WinSrv2022"
    $ipAddress = "10.10.80.143"
    $hostName="winfra.surf"
    $MacAddressWhereStaticIP = PSHyperVLabNet\Get-MACAddressFromString "$VMName-BrotlyNet_Internal"
    Get-VM -VMName $VMName | Get-VMNetworkAdapter  | Where-Object {$_.MacAddress -eq $MacAddressWhereStaticIP} | PSHyperVLabNet\Set-VMNetworkConfiguration -IPAddress $ipAddress -Subnet "255.255.255.0"
    PSHyperVLabNet\RemoveFromHosts -Hostname $hostName
    PSHyperVLabNet\AddToHosts -Hostname $hostName -DesiredIp $ipAddress
    
    # for Ubuntu22.04 (linfra.surf)
    $VMName="Ubuntu22.04"
    $ipAddress = "10.10.80.141"
    $hostName="linfra.surf"
    $MacAddressWhereStaticIP = PSHyperVLabNet\Get-MACAddressFromString "$VMName-BrotlyNet_Internal"
    Get-VM -VMName $VMName | Get-VMNetworkAdapter  | Where-Object {$_.MacAddress -eq $MacAddressWhereStaticIP} | PSHyperVLabNet\Set-VMNetworkConfiguration -IPAddress $ipAddress -Subnet "255.255.255.0"
    PSHyperVLabNet\RemoveFromHosts -Hostname $hostName
    PSHyperVLabNet\AddToHosts -Hostname $hostName -DesiredIp $ipAddress
    
    # for HyperVSrv2019 (hv.surf)
    $VMName="HyperVSrv2019"
    $ipAddress = "10.10.80.87"
    $hostName="hv.surf"
    $MacAddressWhereStaticIP = PSHyperVLabNet\Get-MACAddressFromString "$VMName-BrotlyNet_Internal"
    Get-VM -VMName $VMName | Get-VMNetworkAdapter  | Where-Object {$_.MacAddress -eq $MacAddressWhereStaticIP} | PSHyperVLabNet\Set-VMNetworkConfiguration -IPAddress $ipAddress -Subnet "255.255.255.0"
    PSHyperVLabNet\RemoveFromHosts -Hostname $hostName
    PSHyperVLabNet\AddToHosts -Hostname $hostName -DesiredIp $ipAddress
    
}