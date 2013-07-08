node 'hetz3.black.co.at' {
  class { 'dasz::defaults':
    location         => hetzner,
    ssh_port         => 2200,
    force_nullmailer => true;
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
  }

  openvpn::tunnel {
    'dasz-bridge':
      port     => 1197,
      proto    => 'udp',
      mode     => 'server',
      template => "site/${::fqdn}/openvpn_dasz-bridge.conf.erb";

    'maria':
      port     => 1195,
      proto    => 'tcp',
      mode     => 'server',
      template => "site/${::fqdn}/openvpn_maria.conf.erb";
  }

  site::ovpn_keys { ['dasz', 'maria']: }
}
