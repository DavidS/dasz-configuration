class hosting::secondary_ns {
  include dasz::defaults, bind

  concat { "/etc/bind/named.conf.local":
    mode    => 644,
    owner   => root,
    group   => root,
    require => Class['bind::installation'],
    notify  => Class['bind::service'];
  }
 
  Concat::Fragment <<| tag == 'hosting::domain::slave' |>>
}