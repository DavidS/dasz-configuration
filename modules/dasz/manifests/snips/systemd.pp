# Install systemd and configure grub to use non-standard init
class dasz::snips::systemd ($grub_template = 'dasz/systemd-grub.conf.erb', $grub_timeout = 5) {
  package { 'systemd': ensure => installed; }

  file { "/etc/default/grub":
    ensure  => present,
    content => template($grub_template),
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