node 'dc.dasz.at' {
  class { 'dasz::defaults':
    location    => tech21,
    admin_users => false; # collides with local ldap setup
  }
}