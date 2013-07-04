node 'hetz3.black.co.at' {
  class { 'dasz::defaults':
    location => hetzner,
    ssh_port => 2200;
  }

  class {
    'libvirt':
    ;

    'openvpn':
    ;
  }

  # foreman virt host
  $home = '/var/lib/foreman-mgr'

  user { 'foreman-mgr':
    ensure     => present,
    system     => true,
    home       => $home,
    managehome => true,
    groups     => ['libvirt'],
    require    => Package['libvirt'];
  }

  file {
    "${home}/.ssh":
      ensure => directory,
      owner  => 'foreman-mgr',
      group  => 'foreman-mgr',
      mode   => 0700;

    "${home}/.ssh/authorized_keys":
      source => "puppet:///modules/site/foreman-authorized_keys",
      owner  => 'foreman-mgr',
      group  => 'foreman-mgr',
      mode   => 0600;

    "/etc/openvpn/dasz-ca":
      ensure => directory,
      mode   => '0700',
      owner  => root,
      group  => root;

    "/etc/openvpn/dasz-ca/keys":
      ensure  => directory,
      mode    => '0700',
      owner   => root,
      group   => root,
      source  => 'puppet:///secrets/openvpn_ca/dasz-ca/keys',
      ignore  => ['*.key', '*.csr'],
      recurse => true,
      force   => true,
      purge   => true;
  }

  openvpn::tunnel {
    'dasz-lan':
      port     => 1197,
      template => 'site/hosting3.edv-bus.at/openvpn_dasz-lan.conf.erb';

    'dasz-lan-david-nb':
      port     => 1198,
      server   => '10.254.0.5 10.254.0.6',
      template => 'site/hosting3.edv-bus.at/openvpn_dasz-lan-nb.conf.erb';

    'dasz-lan-arthur-nb':
      port     => 1199,
      server   => '10.254.0.9 10.254.0.10',
      template => 'site/hosting3.edv-bus.at/openvpn_dasz-lan-nb.conf.erb';
  }
}