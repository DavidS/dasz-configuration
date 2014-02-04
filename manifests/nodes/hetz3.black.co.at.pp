node 'hetz3.black.co.at' {
  class { 'dasz::defaults':
    location          => hetzner,
    ssh_port          => 2200,
    munin_smart_disks => ['sda', 'sdb'],
    force_nullmailer  => true;
  }

  class {
    'libvirt':
    ;

    'openvpn':
    ;

    'hosting::secondary_ns':
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

  file {
    "/etc/network/interfaces":
      ensure  => present,
      content => template("site/${::fqdn}/interfaces.erb");

    "/etc/dhcp/dhclient.conf":
      ensure  => present,
      content => template("site/${::fqdn}/dhclient.conf.erb");

    "/etc/openvpn/dasz_up":
      ensure  => present,
      content => template("site/${::fqdn}/dasz_up.erb"),
      mode    => 0755,
      owner   => root,
      group   => root,
      notify  => Service['openvpn'];

    "/etc/openvpn/dasz_down":
      ensure  => present,
      content => template("site/${::fqdn}/dasz_down.erb"),
      mode    => 0755,
      owner   => root,
      group   => root,
      notify  => Service['openvpn'];
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

  nginx::vhost {
    'default':
      docroot        => 'none',
      create_docroot => false,
      template       => "site/${::fqdn}/nginx-default.site.erb";

    'office.dasz.at':
      docroot        => 'none',
      create_docroot => false,
      template       => "site/${::fqdn}/nginx-office.dasz.at.site.erb";
  }

  # required so that nginx finds the upstrem servers at dasz lan
  host {
    "office":
      ip     => '10.0.0.221',
      notify => Service['nginx'];

    'monitor':
      ip     => '10.0.0.217',
      notify => Service['nginx'];

    'kvmhost':
      ip     => '10.0.0.191',
      notify => Service['nginx'];
  }

  file {
    '/etc/nginx/sites-available/default':
      ensure => absent;

    '/etc/nginx/certs':
      ensure => directory,
      mode   => 0750,
      owner  => root,
      group  => 'www-data',
      notify => Service['nginx'];

    '/etc/nginx/certs/office.dasz.at.key':
      ensure => present,
      source => 'puppet:///secrets/ssl/office.dasz.at.key',
      mode   => 0440,
      owner  => root,
      group  => 'www-data',
      notify => Service['nginx'];

    '/etc/nginx/certs/office.dasz.at.bundle.crt':
      ensure => present,
      source => 'puppet:///secrets/ssl/office.dasz.at.bundle.crt',
      mode   => 0440,
      owner  => root,
      group  => 'www-data',
      notify => Service['nginx'];

    '/srv/dasz':
      ensure => directory,
      mode   => 0750,
      owner  => david,
      group  => www-data,
      before => Service['nginx'];
  }
}
