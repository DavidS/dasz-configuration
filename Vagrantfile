# -*- mode: ruby -*-
# vi: set ft=ruby :

# Vagrantfile API/syntax version. Don't touch unless you know what you're doing!
VAGRANTFILE_API_VERSION = "2"
PRIVATE_SUBNET = ENV["PRIVATE_SUBNET"] || '192.168.13'

Vagrant.configure(VAGRANTFILE_API_VERSION) do |config|
  # All Vagrant configuration is done here. The most common configuration
  # options are documented and commented below. For a complete reference,
  # please see the online documentation at vagrantup.com.

  def private_ip(index)
    PRIVATE_SUBNET + "." + index
  end

  def provision_with_puppet(vm)
    vm.provision "shell", :inline => "/vagrant/scripts/register_puppetmaster #{private_ip("4")} puppetmaster.example.org"

    vm.provision "puppet_server" do |puppet|
      puppet.puppet_server  = "puppetmaster.example.org"
      puppet.options = [ '--test', '--summarize', '--pluginsync' ]
    end
  end

  # Every Vagrant virtual environment requires a box to build off of.
  config.vm.box = "Debian-7.4.0-amd64"
  config.vm.box_url = "http://jenkins:8080/view/zetbox.Appliance/job/appliance-develop-build-basebox/lastSuccessfulBuild/artifact/Builder/veewee/Debian-7.4.0-amd64-netboot.box"

  config.vm.define "puppetmaster" do |pm_config|
    pm_config.vm.host_name = "puppetmaster.example.org"
    pm_config.vm.network "forwarded_port", guest: 80, host: 8080   # foreman
    pm_config.vm.network "forwarded_port", guest: 3140, host: 3140 # puppetmaster
    pm_config.vm.network "private_network", ip: private_ip("4")

    # The puppetmaster and friends need oodles of memory
    pm_config.vm.provider "virtualbox" do |vb|
      vb.memory = 1024
      vb.cpus = 2
    end

    pm_config.vm.provision :puppet do |puppet|
      puppet.manifests_path = "manifests"
      puppet.manifest_file  = "puppetmaster.pp"
      puppet.module_path    = [ "modules" ]
      puppet.options = [ '--verbose', '--show_diff', '--summarize', '--pluginsync' ]
    end
  end

  config.vm.define "monitor" do |pm_config|
    pm_config.vm.host_name = "monitor.example.org"
    pm_config.vm.network "forwarded_port", guest: 80, host: 8082
    pm_config.vm.network "private_network", ip: private_ip("5")

    provision_with_puppet(pm_config.vm)
  end

  config.vm.define "testagent" do |pm_config|
    pm_config.vm.host_name = "testagent.example.org"
    pm_config.vm.network "forwarded_port", guest: 80, host: 8081
    pm_config.vm.network "forwarded_port", guest: 443, host: 8443
    pm_config.vm.network "private_network", ip: private_ip("50")

    provision_with_puppet(pm_config.vm)
  end

  config.vm.define "empty" do |pm_config|
    pm_config.vm.host_name = "empty.example.org"
    pm_config.vm.network "private_network", ip: private_ip("60")

    pm_config.vm.provision "shell", :inline => "/vagrant/scripts/register_puppetmaster #{private_ip("4")} puppetmaster.example.org"
  end
end
