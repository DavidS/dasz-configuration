class hosting::secondary_ns {
  include bind

  concat { "/etc/bind/named.conf.local":
    mode    => 644,
    owner   => root,
    group   => root,
    require => Class['bind::installation'],
    notify  => Class['bind::service'];
  }

  Concat::Fragment <<| tag == 'hosting::domain::slave' |>>

  # bind service file required for reliable restarting
  file { "/etc/systemd/system/bind9.service":
    source => "puppet:///modules/hosting/systemd.bind9.service",
    mode   => 0644,
    owner  => root,
    group  => root,
    notify => [Exec['systemd-reload'], Class['bind::service']];
  }
  # require that systemd reloads before updating the bind9 service
  Exec['systemd-reload'] -> Class['bind::service']
}
