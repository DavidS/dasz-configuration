node 'dc.dasz.at' {
  class { 'dasz::defaults':
    location    => tech21,
    admin_users => false; # collides with local ldap setup
  }
  file {
    '/etc/munin/plugins/ttys_temp':
      ensure => link,
      target => '/etc/munin/ttys_temp',
      notify => Service['munin-node'];
    '/etc/munin/plugins/sensors':
      ensure => link,
      target => '/etc/munin/sensors',
      notify => Service['munin-node'];
  }
}
