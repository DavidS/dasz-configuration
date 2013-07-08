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
    'dasz-lan':
      port     => 1197,
      proto    => 'udp',
      server   => '10.254.0.1 10.254.0.2',
      template => 'site/hosting3.edv-bus.at/openvpn_dasz-lan.conf.erb';

    'dasz-lan-david-nb':
      port     => 1198,
      proto    => 'udp',
      server   => '10.254.0.5 10.254.0.6',
      template => 'site/hosting3.edv-bus.at/openvpn_dasz-lan-nb.conf.erb';

    'dasz-lan-arthur-nb':
      port     => 1199,
      proto    => 'udp',
      server   => '10.254.0.9 10.254.0.10',
      template => 'site/hosting3.edv-bus.at/openvpn_dasz-lan-nb.conf.erb';

    'maria':
      port     => 1195,
      proto    => 'tcp-server',
      template => 'site/hosting3.edv-bus.at/openvpn_maria.conf.erb';
  }

  site::ovpn_keys { ['dasz', 'maria']: }
}
