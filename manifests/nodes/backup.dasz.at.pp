node 'backup.dasz.at' {
  class {
    'dasz::defaults':
      location          => at,
      munin_smart_disks => ['sda', 'sdb', 'sdc', 'sdd'], # backup disks may not be well-checkable
      force_nullmailer  => true;

    'dasz::snips::systemd':
    ;

    'site::internal_hosts':
    ;

    'openvpn':
    ;
  }

  ##################################################################
  # #  BACKUP  #####################################################
  ##################################################################

  package {
    'backuppc':
      ensure => installed;

    # ensure that those are purged, because the locate.db contains /var/lib/backuppc, which nobody wants!
    [
      "locate",
      "mlocate"]:
      ensure => purged;
  }

  file {
    "/etc/backuppc":
      source  => "puppet:///secrets/backuppc",
      recurse => true,
      require => Package['backuppc'],
      notify  => Service['backuppc'];

    "/etc/backuppc/ssh/id_rsa":
      source  => "puppet:///secrets/backuppc/ssh/id_rsa",
      mode    => 0600,
      owner   => backuppc,
      group   => backuppc,
      require => Package['backuppc'],
      notify  => Service['backuppc'];
  }

  service { 'backuppc':
    ensure => 'running',
    enable => true;
  }

  package { 'festival': ensure => installed; }

  file {
    "/root/bin/remounter":
      source => "puppet:///modules/site/backuppc/remounter",
      mode   => 0755,
      owner  => root,
      group  => root;

    "/root/bin/remounter-core":
      source => "puppet:///modules/site/backuppc/remounter-core",
      mode   => 0755,
      owner  => root,
      group  => root;

    "/etc/udev/rules.d/99-backup.rules":
      source => "puppet:///modules/site/backuppc/udev.rules",
      mode   => 0644,
      owner  => root,
      group  => root;

    [
      "/media/backup1",
      "/media/backup2",
      "/media/backup3"]:
      ensure => directory;
  }

  sudo::directive { "backuppc-local": content => "backuppc ALL=(ALL) NOPASSWD: /usr/bin/env LC_ALL=C /bin/tar -c -v -f - -C *\n", }

  mount {
    "/media/backup1":
      ensure  => defined,
      atboot  => false,
      device  => "LABEL=backup1",
      fstype  => "ext3",
      options => "noauto,relatime";

    "/media/backup2":
      ensure  => defined,
      atboot  => false,
      device  => "LABEL=backup2",
      fstype  => "ext3",
      options => "noauto,relatime";

    "/media/backup3":
      ensure  => defined,
      atboot  => false,
      device  => "LABEL=backup3",
      fstype  => "ext3",
      options => "noauto,relatime";
  }

  ##################################################################
  # #  SHOWSLIDE  ##################################################
  ##################################################################
  file {
    "/root/bin/showslide":
      source => "puppet:///modules/site/showslide",
      mode   => 0755,
      owner  => root,
      group  => root;

    "/etc/systemd/system/showslide.service":
      source => "puppet:///modules/site/showslide.service",
      mode   => 0644,
      owner  => root,
      group  => root;

    "/srv/images":
      ensure => directory;
  }

  package { "fbi": ensure => installed; }

  service { "showslide.service":
    ensure    => running,
    enable    => true,
    provider  => systemd,
    subscribe => [File["/root/bin/showslide", "/etc/systemd/system/showslide.service"], Package["fbi"]];
  }

  ##################################################################
  # #  OPENVPN  ####################################################
  ##################################################################

  site::ovpn_keys { 'maria': }

  # additional keying material for mariatreu vpn
  file {
    '/etc/openvpn/keys':
      ensure => directory,
      mode   => '0700',
      owner  => root,
      group  => root;
    '/etc/openvpn/keys/maria.key':
      source => 'puppet:///secrets/openvpn/maria.key',
      mode   => '0600',
      owner  => root,
      group  => root;
  }

  openvpn::tunnel { 'maria':
    port     => 1195,
    proto    => 'tcp',
    mode     => 'client',
    remote   => 'hetz3.black.co.at',
    dev      => 'tap',
    template => "site/${::fqdn}/openvpn_maria-client.conf.erb";
  }
}
