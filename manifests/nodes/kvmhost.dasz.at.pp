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

  # misc
  package { "vagrant": ensure => installed; }

  apt::repository {
    "experimental-src":
      url        => "http://kvmhost.dasz:3142/debian",
      distro     => experimental,
      repository => "main",
      src_repo   => true;

    "wheezy-src":
      url        => "http://kvmhost.dasz:3142/debian",
      distro     => wheezy,
      repository => "main",
      src_repo   => true;

    "jessie-src":
      url        => "http://kvmhost.dasz:3142/debian",
      distro     => jessie,
      repository => "main",
      src_repo   => true;
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

    '/var/lib/jenkins_slave/.config/NuGet/NuGet.Config':
      ensure  => present,
      content => template("dasz/jenkins/NuGet.Config.erb"),
      owner   => slave,
      group   => nogroup,
      mode    => 0600;
  }

  user { "slave":
    system => true,
    home   => '/var/lib/jenkins_slave';
  }

  service { "jenkins_slave.service":
    provider  => systemd,
    ensure    => running,
    enable    => true,
    require   => User['slave'],
    subscribe => File['/etc/systemd/system/jenkins_slave.service'];
  }

  # import certificates from mozilla
  exec { "/usr/bin/mozroots --import --sync":
    refreshonly => true,
    subscribe   => Package['mono-complete'];
  }

  # zetbox package mirror
  # see /srv/debian/README for details
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

  # preliminary cowbuilder support
  package { "cowbuilder": ensure => installed; }

  $debian_mirror = 'kvmhost.dasz:3142'
  $basedir = '/var/cache/pbuilder'

  $dist = 'wheezy'
  $arch = 'amd64'

  file { # cache dir for dist/arch
    "${basedir}/${dist}-${arch}":
      ensure  => directory,
      mode    => 0755,
      owner   => root,
      group   => root,
      require => Package["cowbuilder"];

    "/etc/pbuilderrc":
      content => template("dasz/jenkins/pbuilderrc.erb"),
      mode    => 0644,
      owner   => root,
      group   => root;
  }

  exec { "cowbuilder create ${dist}-${arch}":
    command => "/usr/sbin/cowbuilder --create --basepath /var/cache/pbuilder/${dist}-${arch}/base.cow --distribution ${dist} --debootstrapopts --arch --debootstrapopts ${arch}",
    require => [File["${basedir}/${dist}-${arch}"], File["/etc/pbuilderrc"]],
    creates => "${basedir}/${dist}-${arch}/base.cow";
  }
}
