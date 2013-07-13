node 'hosting3.edv-bus.at' {
  class { 'dasz::defaults': location => hetzner; }

  package { 'systemd': ensure => installed; }

  file { "/etc/default/grub":
    ensure  => present,
    source  => 'puppet:///modules/dasz/systemd-grub.conf',
    mode    => 0644,
    owner   => root,
    group   => root,
    require => Package['systemd'],
    notify  => Exec['update-grub'];
  }

  exec { 'update-grub':
    refreshonly => true,
    path        => '/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin';
  }
}
