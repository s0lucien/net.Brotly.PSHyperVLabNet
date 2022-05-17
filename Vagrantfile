Vagrant.configure("2") do |config|

    config.vm.define "linfra" do |node|
        node.vm.box = "brotly/Ubuntu20.04.4"

        node.vm.provider "hyperv" do |hv|
          hv.vmname = "Ubuntu20.04.4"
          hv.cpus = `powershell.exe -Command "$(Get-WmiObject -class Win32_processor | select NumberOfLogicalProcessors).NumberOfLogicalProcessors"`
          hv.ip_address_timeout=300
          hv.memory = 2048
        end
    end

    config.vm.define "winfra" do |node|
      node.vm.box = "brotly/WinSrv2022"

      node.vm.provider "hyperv" do |hv|
        hv.vmname = "WinSrv2022"
        hv.cpus = `powershell.exe -Command "$(Get-WmiObject -class Win32_processor | select NumberOfLogicalProcessors).NumberOfLogicalProcessors"`
        hv.ip_address_timeout=300
        hv.memory = 2048
        end
    end

    config.vm.define "hv" do |node|
      node.vm.box = "brotly/HyperVSrv2019"

      node.vm.provider "hyperv" do |hv|
        hv.vmname = "HyperVSrv2019"
        hv.cpus = `powershell.exe -Command "$(Get-WmiObject -class Win32_processor | select NumberOfLogicalProcessors).NumberOfLogicalProcessors"`
        hv.ip_address_timeout=300
        hv.memory = 4096
        end
    end
  end