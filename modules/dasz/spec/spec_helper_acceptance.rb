require 'beaker-rspec/spec_helper'
require 'beaker-rspec/helpers/serverspec'


unless ENV['RS_PROVISION'] == 'no'
  hosts.each do |host|
    if host['platform'] =~ /debian/
      on host, 'echo \'export PATH=/var/lib/gems/1.8/bin/:${PATH}\' >> ~/.bashrc'
    end
    if host.is_pe?
      install_pe
    else
      install_puppet
      on host, "mkdir -p #{host['distmoduledir']}"
    end
  end
end

UNSUPPORTED_PLATFORMS = ['Suse','windows','AIX','Solaris']

RSpec.configure do |c|
  # Project root
  proj_root = File.expand_path(File.join(File.dirname(__FILE__), '..'))

  # Readable test descriptions
  c.formatter = :documentation

  # Configure all nodes in nodeset
  c.before :suite do
    # Install module and dependencies
    [ "apache", "dhcpd", "hosting", "munin", "openssh", "registry", "tftp",
      "apt", "dovecot", "icinga", "mysql", "openvpn", "roundcube", "timezone",
      "bind", "exim", "inittab", "nginx", "postgresql", "rsyslog", "vcsrepo",
      "chocolatey", "exiscan", "iptables", "nrpe", "puppet", "site", "xinetd",
      "concat", "firewall", "libvirt", "ntp", "puppetdb", "stdlib",
      "dasz", "foreman", "monitor", "nullmailer", "puppi", "sudo"
    ].each do |m|
      scp_to(hosts, '../'+m, '/etc/puppet/modules/'+m)
    end
    on hosts, "mkdir -p /srv/puppet"
    scp_to(hosts, 'spec/acceptance/secrets', '/srv/puppet/secrets')
    # etckeeper chokes on submodule's .git refs
    on hosts, "find /etc/puppet/modules -name .git | xargs rm -rf"
  end
end
