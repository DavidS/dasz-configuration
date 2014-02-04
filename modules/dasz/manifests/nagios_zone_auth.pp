define dasz::nagios_zone_auth ($ns = []) {
  @@file { "/etc/nagios3/conf.d/zone_${name}.cfg":
    ensure  => present,
    content => template("dasz/nagios-check_zone_auth.cfg.erb"),
    mode    => 0644,
    owner   => root,
    group   => root,
    tag     => 'nagios_host_',
    require => Package['nagios3'],
    notify  => Service['nagios3'];
  }
}