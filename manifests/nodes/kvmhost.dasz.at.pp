node 'kvmhost.dasz.at' {
  class {
    'dasz::defaults':
      location          => tech21,
      munin_smart_disks => ['sda', 'sdb'],
      force_nullmailer  => true;

    'dasz::snips::systemd':
    ;

    'nginx':
    ;
  }

  # use mono3
  apt::repository { "zetbox":
    url        => "http://kvmhost.dasz/debian",
    distro     => zetbox,
    repository => "main";
  }

  package { "mono-complete": ensure => installed; }

  # jenkins slave
  package { "openjdk-7-jre-headless": ensure => installed; }

  file {
    "/etc/systemd/system/jenkins_slave.service":
      ensure  => present,
      content => template('dasz/jenkins/jenkins_slave.service.erb'),
      owner   => root,
      group   => root,
      mode    => 0644;

    [
      '/var/lib/jenkins_slave/.config',
      '/var/lib/jenkins_slave/.config/NuGet']:
      ensure => directory,
      owner  => slave,
      group  => nogroup,
      mode   => 0700;

    '/var/lib/jenkins_slave/.config/NuGet/NuGet.config':
      ensure  => present,
      content => template("dasz/jenkins/NuGet.config.erb"),
      owner   => slave,
      group   => nogroup,
      mode    => 0600;
  }

  user { "slave":
    system => true,
    home   => '/var/lib/jenkins_slave';
  }

  service { "jenkins_slave":
    ensure    => running,
    enable    => true,
    require   => User['slave'],
    subscribe => File['/etc/systemd/system/jenkins_slave.service'];
  }

  # zetbox package mirror
  package { "reprepro": ensure => installed; }

  nginx::vhost { 'kvmhost':
    docroot    => '/srv/debian',
    groupowner => 'adm';
  }

  file { ["/srv/debian/conf", "/srv/debian/incoming"]:
    ensure => directory,
    owner  => root,
    group  => adm,
    mode   => 0775;
  }

  # apt-cacher
  package { "apt-cacher": ensure => installed; }

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