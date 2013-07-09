node 'dc.dasz.at' {
  class { 'dasz::defaults':
    location          => tech21,
    admin_users       => false, # collides with local ldap setup
    munin_smart_disks => ['sda', 'sdb', 'sdc', 'sdd'], # backup disks may not be well-checkable
    force_nullmailer  => true;
  }

  munin::plugin {
    'sensors_temp':
      target => "${munin::plugins_dir}/sensors_";

    'ping_8.8.8.8':
      target => "${munin::plugins_dir}/ping_";

    'ping_hosting.edv-bus.at':
      target => "${munin::plugins_dir}/ping_";

    'ping_www.uni-ak.ac.at':
      target => "${munin::plugins_dir}/ping_";

    'ttys_temp':
      source => 'puppet:///modules/dasz/munin/dc_ttys_temp';
  }

  openvpn::tunnel { 'dasz-bridge':
    port     => 1197,
    proto    => 'udp',
    server   => '10.254.0.2 10.254.0.1',
    template => "site/${::fqdn}/openvpn_dasz-bridge.conf.erb";
  }

  site::ovpn_keys { 'dasz': }
}
