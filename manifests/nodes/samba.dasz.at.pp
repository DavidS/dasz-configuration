node 'samba.dasz.at' {
  class { 'dasz::defaults':
    location          => tech21,
    admin_users       => false, # collides with local ldap setup
    munin_smart_disks => ['sda'],
    force_nullmailer  => true;
  }
}
