node 'dc.dasz.at' {
  class { 'dasz::defaults':
    location    => tech21,
    admin_users => false; # collides with local ldap setup
  }
  munin::plugin {
    'sensors_temp':
      linkplugins => true,
      linktarget  => 'sensors_';
    'ttys_temp':
      source      => 'dasz/munin/dc_ttys_temp',
      linkplugins => true;
  }
}
