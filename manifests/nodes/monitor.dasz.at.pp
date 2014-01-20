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

    'apache':
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

  apache::dotconf { "munin": content => template('dasz/munin/apache.conf.erb'); }

  file { "/etc/munin/munin-conf.d/graph_width.conf":
    content => "graph_width 600\n",
    mode    => 0644,
    owner   => root,
    group   => root;
  }

  # collect manual nagios definitions (currently only windows hosts)
  File <<| tag == 'nagios_host_' |>>

  package { ["nagios3", "nagios-nrpe-plugin"]:
    ensure => present,
    notify => Service['nagios3'];
  }

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

  dasz::zetbox::monitor { 'dasz-prod':
    url       => "https://office.dasz.at/dasz/PerfMon.facade",
    fake_host => 'srv2008-monitor';
  }

  dasz::zetbox::monitor_fake_host { 'srv2008-monitor': folder => 'Tech21'; }
}
