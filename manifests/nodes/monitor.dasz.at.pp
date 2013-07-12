node 'monitor.dasz.at' {
  class {
    'dasz::defaults':
      location         => tech21,
      munin_node       => false,
      force_nullmailer => true;

    'munin':
      folder            => 'Tech21',
      server            => $::ipaddress,
      server_local      => true,
      include_dir_purge => true,
      graph_strategy    => cgi;

    'munin::cgi':
    ;
  }

  # manually configured server
  @@file { "${munin::include_dir}/manual-servers.conf":
    ensure  => $munin::manage_file,
    path    => "${munin::include_dir}/manual-servers.conf",
    mode    => $munin::config_file_mode,
    owner   => $munin::config_file_owner,
    group   => $munin::config_file_group,
    content => template("site/munin/manual-servers.conf.erb"),
    tag     => "munin_host_${munin::magic_tag}",
  }

  # collect manual nagios definitions (currently only windows hosts)
  File <<| tag == 'nagios_host_' |>>

  file { "/etc/nagios3/conf.d/windows.cfg":
    ensure  => present,
    content => template("dasz/nagios-windows-base.cfg.erb"),
    mode    => 0644,
    owner   => root,
    group   => root,
    notify  => Service['nagios3'];
  }
  service { 'nagios3':
    ensure => running,
    enable => true,
  }
}
