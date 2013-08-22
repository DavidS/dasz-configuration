node 'kvmhost.dasz.at' {
  class {
    'dasz::defaults':
      location          => tech21,
      munin_smart_disks => ['sda', 'sdb'],
      force_nullmailer  => true;

    'nginx':
    ;
  }

  apt::repository { "zetbox":
    url        => "http://kvmhost.dasz/debian",
    distro     => zetbox,
    repository => "main";
  }

  nginx::vhost { 'kvmhost':
    docroot    => '/srv/debian',
    groupowner => 'adm';
  }

  package { ["apt-cacher", "reprepro", "mono-complete"]: ensure => installed; }

  file {
    "/etc/default/apt-cacher":
      source => "puppet:///modules/dasz/apt-cacher/default",
      notify => Service['apt-cacher'];

    "/etc/apt-cacher/apt-cacher.conf":
      source => "puppet:///modules/dasz/apt-cacher/apt-cacher.conf.tech21",
      notify => Service['apt-cacher'];

    [
      "/srv/debian/conf",
      "/srv/debian/incoming"]:
      ensure => directory,
      owner  => root,
      group  => adm,
      mode   => 0775;
  }

  service { 'apt-cacher':
    ensure  => running,
    enable  => true,
    require => Package['apt-cacher'];
  }
}