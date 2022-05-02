function Setup-HyperVLabNet {
    ### Create vNICs
    # raspberry MACs
    PSHyperVLabNet\Add-VMNetworkAdapter -VMName "rpi" -SwitchName "BrotlyNet_host"
    PSHyperVLabNet\Add-VMNetworkAdapter -VMName "rpi" -SwitchName "BrotlyNet_pf2vm"
    
    # winfra MACs
    PSHyperVLabNet\Add-VMNetworkAdapter -VMName "WinSrv2022" -SwitchName "BrotlyNet_host"
    PSHyperVLabNet\Add-VMNetworkAdapter -VMName "WinSrv2022" -SwitchName "BrotlyNet_pf2vm"

    # linfra MACs
    PSHyperVLabNet\Add-VMNetworkAdapter -VMName "Ubuntu22.04" -SwitchName "BrotlyNet_host"
    PSHyperVLabNet\Add-VMNetworkAdapter -VMName "Ubuntu22.04" -SwitchName "BrotlyNet_pf2vm"

    # hv MACs
    PSHyperVLabNet\Add-VMNetworkAdapter -VMName "HyperVSrv2019" -SwitchName "BrotlyNet_host"
    PSHyperVLabNet\Add-VMNetworkAdapter -VMName "HyperVSrv2019" -SwitchName "BrotlyNet_pf2vm"


    # # pfsense MACs
    # PSHyperVLabNet\Add-VMNetworkAdapter -VMName "pfSense" -SwitchName "BrotlyNet_host"
    # PSHyperVLabNet\Add-VMNetworkAdapter -VMName "pfSense" -SwitchName "BrotlyNet_pf2vm"
    # # share host internet connection using the NATed 'Default Switch'
    # PSHyperVLabNet\Add-VMNetworkAdapter -VMName "pfSense" -SwitchName "Default Switch"

    ### Create vSwitches
    # PSHyperVLabNet\New-VMSwitch -name "BrotlyNet_pf2vm" -type "Private"
    # PSHyperVLabNet\New-VMSwitch -name "BrotlyNet_host" -type "Internal"

    ### Connect VMs to vSwitches
    # raspberry NICs
    PSHyperVLabNet\Connect-VMNetworkAdapter -VMName "rpi" -SwitchName "BrotlyNet_host"
    PSHyperVLabNet\Connect-VMNetworkAdapter -VMName "rpi" -SwitchName "BrotlyNet_pf2vm"

    # winfra NICs
    PSHyperVLabNet\Connect-VMNetworkAdapter -VMName "WinSrv2022" -SwitchName "BrotlyNet_host"
    PSHyperVLabNet\Connect-VMNetworkAdapter -VMName "WinSrv2022" -SwitchName "BrotlyNet_pf2vm"

    # linfra NICss
    PSHyperVLabNet\Connect-VMNetworkAdapter -VMName "Ubuntu22.04" -SwitchName "BrotlyNet_host"
    PSHyperVLabNet\Connect-VMNetworkAdapter -VMName "Ubuntu22.04" -SwitchName "BrotlyNet_pf2vm"

    # hv NICss
    PSHyperVLabNet\Connect-VMNetworkAdapter -VMName "HyperVSrv2019" -SwitchName "BrotlyNet_host"
    PSHyperVLabNet\Connect-VMNetworkAdapter -VMName "HyperVSrv2019" -SwitchName "BrotlyNet_pf2vm"

    # # pfsense NICs
    # PSHyperVLabNet\Connect-VMNetworkAdapter -VMName "pfSense" -SwitchName "BrotlyNet_host"
    # PSHyperVLabNet\Connect-VMNetworkAdapter -VMName "pfSense" -SwitchName "BrotlyNet_pf2vm"
    # # connect to internet using the NATed 'Default Switch'
    # PSHyperVLabNet\Connect-VMNetworkAdapter -VMName "pfSense" -SwitchName "Default Switch"

}