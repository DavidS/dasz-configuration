node 'samba.dasz.at' {
  class { 'dasz::defaults':
    location          => tech21,
    admin_users       => false, # collides with local ldap setup
    munin_smart_disks => ['sda', 'sdb', 'sdc', 'sdd'], # backup disks may not be well-checkable
    force_nullmailer  => true;
  }

  package { 'backuppc': ensure => installed; }

  file { "/etc/backuppc":
    source  => "puppet:///secrets/backuppc",
    recurse => true,
    require => Package['backuppc'],
    notify  => Service['backuppc'];
  }

  service { 'backuppc':
    ensure => 'running',
    enable => true;
  }
}
