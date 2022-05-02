function Setup-HyperVLabNet ($NetPrefix = "BrotlyNet") {
    ### Create vNICs
    # raspberry MACs

    #IDEMPOTENT : remove before add to start from clean state
    PSHyperVLabNet\Remove-VMNetworkAdapter -VMName "rpi" -SwitchName "$($NetPrefix)_host"
    PSHyperVLabNet\Remove-VMNetworkAdapter -VMName "rpi" -SwitchName "$($NetPrefix)_pf2vm"
    #END IDEMPOTENT
    PSHyperVLabNet\Add-VMNetworkAdapter -VMName "rpi" -SwitchName "$($NetPrefix)_host"
    PSHyperVLabNet\Add-VMNetworkAdapter -VMName "rpi" -SwitchName "$($NetPrefix)_pf2vm"
    
    # winfra MACs
    #IDEMPOTENT : remove before add to start from clean state
    PSHyperVLabNet\Remove-VMNetworkAdapter -VMName "WinSrv2022" -SwitchName "$($NetPrefix)_host"
    PSHyperVLabNet\Remove-VMNetworkAdapter -VMName "WinSrv2022" -SwitchName "$($NetPrefix)_pf2vm"
    #END IDEMPOTENT
    PSHyperVLabNet\Add-VMNetworkAdapter -VMName "WinSrv2022" -SwitchName "$($NetPrefix)_host"
    PSHyperVLabNet\Add-VMNetworkAdapter -VMName "WinSrv2022" -SwitchName "$($NetPrefix)_pf2vm"

    # linfra MACs
    #IDEMPOTENT : remove before add to start from clean state
    PSHyperVLabNet\Remove-VMNetworkAdapter -VMName "Ubuntu22.04" -SwitchName "$($NetPrefix)_host"
    PSHyperVLabNet\Remove-VMNetworkAdapter -VMName "Ubuntu22.04" -SwitchName "$($NetPrefix)_pf2vm"
    #END IDEMPOTENT
    PSHyperVLabNet\Add-VMNetworkAdapter -VMName "Ubuntu22.04" -SwitchName "$($NetPrefix)_host"
    PSHyperVLabNet\Add-VMNetworkAdapter -VMName "Ubuntu22.04" -SwitchName "$($NetPrefix)_pf2vm"

    # hv MACs
    #IDEMPOTENT : remove before add to start from clean state
    PSHyperVLabNet\Remove-VMNetworkAdapter -VMName "HyperVSrv2019" -SwitchName "$($NetPrefix)_host"
    PSHyperVLabNet\Remove-VMNetworkAdapter -VMName "HyperVSrv2019" -SwitchName "$($NetPrefix)_pf2vm"
    #END IDEMPOTENT
    PSHyperVLabNet\Add-VMNetworkAdapter -VMName "HyperVSrv2019" -SwitchName "$($NetPrefix)_host"
    PSHyperVLabNet\Add-VMNetworkAdapter -VMName "HyperVSrv2019" -SwitchName "$($NetPrefix)_pf2vm"


    # # pfsense MACs
    # #IDEMPOTENT : remove before add to start from clean state
    # PSHyperVLabNet\Remove-VMNetworkAdapter -VMName "pfSense" -SwitchName "$($NetPrefix)_host"
    # PSHyperVLabNet\Remove-VMNetworkAdapter -VMName "pfSense" -SwitchName "$($NetPrefix)_pf2vm"
    # #END IDEMPOTENT
    # PSHyperVLabNet\Add-VMNetworkAdapter -VMName "pfSense" -SwitchName "$($NetPrefix)_host"
    # PSHyperVLabNet\Add-VMNetworkAdapter -VMName "pfSense" -SwitchName "$($NetPrefix)_pf2vm"
    # # share host internet connection using the NATed 'Default Switch'
    # PSHyperVLabNet\Add-VMNetworkAdapter -VMName "pfSense" -SwitchName "Default Switch"

    ### Create vSwitches
    # PSHyperVLabNet\New-VMSwitch -name "$($NetPrefix)_pf2vm" -type "Private"
    # PSHyperVLabNet\New-VMSwitch -name "$($NetPrefix)_host" -type "Internal"

    ### Connect VMs to vSwitches
    # raspberry NICs
    # IDEMPOTENT: remove existing connections to the NIC Mac addresses to start from a clean state
    PSHyperVLabNet\Disconnect-VMNetworkAdapter -VMName "rpi" -SwitchName "$($NetPrefix)_host"
    PSHyperVLabNet\Disconnect-VMNetworkAdapter -VMName "rpi" -SwitchName "$($NetPrefix)_pf2vm"
    # END IDEMPOTENT
    PSHyperVLabNet\Disconnect-VMNetworkAdapter -VMName "rpi" -SwitchName "$($NetPrefix)_host"
    PSHyperVLabNet\Disconnect-VMNetworkAdapter -VMName "rpi" -SwitchName "$($NetPrefix)_pf2vm"

    # winfra NICs
    # IDEMPOTENT: remove existing connections to the NIC Mac addresses to start from a clean state
    PSHyperVLabNet\Disconnect-VMNetworkAdapter -VMName "WinSrv2022" -SwitchName "$($NetPrefix)_host"
    PSHyperVLabNet\Disconnect-VMNetworkAdapter -VMName "WinSrv2022" -SwitchName "$($NetPrefix)_pf2vm"
    # END IDEMPOTENT    
    PSHyperVLabNet\Connect-VMNetworkAdapter -VMName "WinSrv2022" -SwitchName "$($NetPrefix)_host"
    PSHyperVLabNet\Connect-VMNetworkAdapter -VMName "WinSrv2022" -SwitchName "$($NetPrefix)_pf2vm"

    # linfra NICs
    # IDEMPOTENT: remove existing connections to the NIC Mac addresses to start from a clean state
    PSHyperVLabNet\Disconnect-VMNetworkAdapter -VMName "Ubuntu22.04" -SwitchName "$($NetPrefix)_host"
    PSHyperVLabNet\Disconnect-VMNetworkAdapter -VMName "Ubuntu22.04" -SwitchName "$($NetPrefix)_pf2vm"
    # END IDEMPOTENT    
    PSHyperVLabNet\Connect-VMNetworkAdapter -VMName "Ubuntu22.04" -SwitchName "$($NetPrefix)_host"
    PSHyperVLabNet\Connect-VMNetworkAdapter -VMName "Ubuntu22.04" -SwitchName "$($NetPrefix)_pf2vm"

    # hv NICs
    # IDEMPOTENT: remove existing connections to the NIC Mac addresses to start from a clean state
    PSHyperVLabNet\Disconnect-VMNetworkAdapter -VMName "HyperVSrv2019" -SwitchName "$($NetPrefix)_host"
    PSHyperVLabNet\Disconnect-VMNetworkAdapter -VMName "HyperVSrv2019" -SwitchName "$($NetPrefix)_pf2vm"
    # END IDEMPOTENT
    PSHyperVLabNet\Connect-VMNetworkAdapter -VMName "HyperVSrv2019" -SwitchName "$($NetPrefix)_host"
    PSHyperVLabNet\Connect-VMNetworkAdapter -VMName "HyperVSrv2019" -SwitchName "$($NetPrefix)_pf2vm"

    # # pfsense NICs
    # IDEMPOTENT: remove existing connections to the NIC Mac addresses to start from a clean state
    PSHyperVLabNet\Disconnect-VMNetworkAdapter -VMName "pfSense" -SwitchName "$($NetPrefix)_host"
    PSHyperVLabNet\Disconnect-VMNetworkAdapter -VMName "pfSense" -SwitchName "$($NetPrefix)_pf2vm"
    # disconnect WAN vSwitch
    PSHyperVLabNet\Disconnect-VMNetworkAdapter -VMName "pfSense" -SwitchName "Default Switch"
    # END IDEMPOTENT
    # PSHyperVLabNet\Connect-VMNetworkAdapter -VMName "pfSense" -SwitchName "$($NetPrefix)_host"
    # PSHyperVLabNet\Connect-VMNetworkAdapter -VMName "pfSense" -SwitchName "$NetPrefix_pf2vm"
    # # connect to internet using the NATed 'Default Switch'
    # PSHyperVLabNet\Connect-VMNetworkAdapter -VMName "pfSense" -SwitchName "Default Switch"

}