# -*- mode: ruby -*-
# vi: set ft=ruby :

Vagrant::Config.run do |config|
  config.vm.define :puppetmaster do |pm_config|
    pm_config.vm.box = "Debian-7.0.0-amd64"
    pm_config.vm.host_name = "puppetmaster.example.org"
    pm_config.vm.forward_port 3140, 3140 # puppetmaster
    pm_config.vm.network :hostonly, "192.168.50.4"

    pm_config.vm.provision :puppet do |puppet|
      puppet.manifests_path = "manifests"
      puppet.manifest_file  = "puppetmaster.pp"
      puppet.module_path    = [ "modules" ]
    end
  end

  config.vm.define :testagent do |pm_config|
    pm_config.vm.box = "Debian-7.0.0-amd64"
    pm_config.vm.host_name = "testagent.example.org"
    pm_config.vm.network :hostonly, "192.168.50.50"

    pm_config.vm.provision :shell, :inline => "/vagrant/scripts/register_puppetmaster 192.168.50.4 puppetmaster.example.org"

    pm_config.vm.provision :puppet_server do |puppet|
      puppet.puppet_server  = "puppetmaster.example.org"
      puppet.options = [ '--test' ]
    end
  end
end
