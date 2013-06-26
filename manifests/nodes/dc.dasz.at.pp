node 'dc.dasz.at' {
  class { 'dasz::defaults':
    location    => tech21,
    admin_users => false; # collides with local ldap setup
  }
  munin::plugin {
    'sensors_temp':
      linkplugins => true,
      linktarget  => 'sensors_';
    'ping_8.8.8.8':
      linkplugins => true,
      linktarget  => 'ping_';
    'ping_hosting.edv-bus.at':
      linkplugins => true,
      linktarget  => 'ping_';
    'ping_www.uni-ak.ac.at':
      linkplugins => true,
      linktarget  => 'ping_';
    'ttys_temp':
      source      => 'dasz/munin/dc_ttys_temp',
      linkplugins => true;
  }
}
