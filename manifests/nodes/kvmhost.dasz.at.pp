node 'kvmhost.dasz.at' {
  class {
    'dasz::defaults':
      location          => tech21,
      munin_smart_disks => ['sda', 'sdb'],
      force_nullmailer  => true;

    'nginx':
    ;
  }

  nginx::vhost { 'kvmhost':
    docroot    => '/srv/debian',
    groupowner => 'adm';
  }

  package { ["apt-cacher", "reprepro"]: ensure => installed; }

  file {
    "/etc/default/apt-cacher":
      source => "puppet:///modules/dasz/apt-cacher/default",
      notify => Service['apt-cacher'];

    "/etc/apt-cacher/apt-cacher.conf":
      source => "puppet:///modules/dasz/apt-cacher/apt-cacher.conf.tech21",
      notify => Service['apt-cacher'];
  }

  service { 'apt-cacher':
    ensure  => running,
    enable  => true,
    require => Package['apt-cacher'];
  }
}