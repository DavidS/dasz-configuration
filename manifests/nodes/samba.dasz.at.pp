node 'samba.dasz.at' {
  class { 'dasz::defaults':
    location          => tech21,
    admin_users       => false, # collides with local ldap setup
    munin_smart_disks => ['sda', 'sdb', 'sdc', 'sdd'], # backup disks may not be well-checkable
    force_nullmailer  => true;
  }

  package { 'backuppc': ensure => installed; }

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

  mount {
    "/media/backup1":
      ensure  => defined,
      atboot  => false,
      device  => "LABEL=backup1",
      fstype  => "ext3",
      options => "relatime";

    "/media/backup2":
      ensure  => defined,
      atboot  => false,
      device  => "LABEL=backup2",
      fstype  => "ext3",
      options => "relatime";

    "/media/backup3":
      ensure  => defined,
      atboot  => false,
      device  => "LABEL=backup3",
      fstype  => "ext3",
      options => "relatime";
  }
}