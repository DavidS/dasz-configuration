node 'monitor.dasz.at' {
  class {
    'dasz::defaults':
      location   => tech21,
      munin_node => false;

    'munin':
      folder         => 'Tech21',
      server         => $::ipaddress,
      server_local   => true,
      graph_strategy => cgi;

    'munin::cgi':
    ;
  }

  # manually configured server
  @@file { "${munin::include_dir}/db-server.conf":
    ensure  => $munin::manage_file,
    path    => "${munin::include_dir}/db-server.conf",
    mode    => $munin::config_file_mode,
    owner   => $munin::config_file_owner,
    group   => $munin::config_file_group,
    content => template("site/munin/db-server.conf.erb"),
    tag     => "munin_host_${munin::magic_tag}",
  }
}
