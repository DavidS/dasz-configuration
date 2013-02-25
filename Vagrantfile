# -*- mode: ruby -*-
# vi: set ft=ruby :

Vagrant::Config.run do |config|
  config.vm.define :puppetmaster do |pm_config|
    pm_config.vm.box = "Debian-7.0.0-amd64"
    pm_config.vm.forward_port 3140, 3140
    pm_config.vm.network :hostonly, "192.168.50.4"

    pm_config.vm.provision :puppet do |puppet|
      puppet.manifests_path = "manifests"
      puppet.manifest_file  = "puppetmaster.pp"
      puppet.module_path    = [ "modules" ]
    end
  end

  config.vm.define :testagent do |pm_config|
    pm_config.vm.box = "Debian-7.0.0-amd64"
    pm_config.vm.network :hostonly, "192.168.50.50"

    pm_config.vm.provision :puppet_server do |puppet|
      puppet.puppet_server  = "192.168.50.4"
      puppet.puppet_node    = "agent01"
    end
  end
end
