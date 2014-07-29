define dasz::nagios_host ($notifications_enabled = 1) {
  # the name should have some contents
  validate_re($name, '.')

  @@file { "/etc/nagios3/conf.d/host_${name}.cfg":
    ensure  => present,
    content => template("dasz/nagios-linux-host.cfg.erb"),
    mode    => 0644,
    owner   => root,
    group   => root,
    tag     => 'nagios_host_',
    require => Package['nagios3'],
    notify  => Service['nagios3'];
  }
}