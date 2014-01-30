# Class: hosting
#
# This module manages hosting
#
# Parameters: none
#
# Actions:
#
# Requires: see Modulefile
#
# Sample Usage:
#
class hosting ($primary_ns_name, $secondary_ns_name, $primary_mx_name, $hosting_ipaddress, $hostmaster,) {
  include dasz::defaults, bind, concat::setup, postgresql, mysql

  if (!defined(Package['git'])) {
    package { git: ensure => installed }
  }

  class { 'nginx':
    template => 'hosting/nginx.frontend.conf.erb'
  }

  # use mono3
  apt::repository { "zetbox":
    url        => $dasz::defaults::location ? {
      'hetzner' => "http://office.dasz.at/debian",
      'tech21'  => "http://kvmhost.dasz/debian",
      'vagrant' => "http://kvmhost.dasz/debian",
      default   => "http://office.dasz.at/debian",
    },
    distro     => zetbox,
    repository => "main",
    trusted    => yes;
  }

  package {
    [
      "mono-complete",
      "mono-fastcgi-server",
      "php5-fpm",
      "php5-gd",
      "php5-mysql",
      "php5-pgsql",
      "php5-sqlite",
      ]:
      ensure => installed;

    "policykit-1":
      ensure => installed,
      notify => Exec['dbus-restart']
  }

  # import certificates from mozilla
  exec { "/usr/bin/mozroots --import --sync":
    refreshonly => true,
    subscribe   => Package['mono-complete'];
  }

  exec {
    'systemd-reload':
      command     => '/bin/systemctl --system daemon-reload',
      refreshonly => true,
      onlyif      => '/bin/systemctl > /dev/null',
      require     => Package['systemd'];

    'dbus-restart':
      command     => '/bin/systemctl restart dbus.service',
      refreshonly => true,
      onlyif      => '/bin/systemctl > /dev/null',
      require     => Package['systemd'];
  }

  file {
    "/etc/nginx/php5-fpm_params":
      source => "puppet:///modules/hosting/nginx.php5-fpm_params",
      mode   => 0644,
      owner  => root,
      group  => root,
      notify => Service['nginx'];

    "/etc/nginx/customer_proxy_params":
      source => "puppet:///modules/hosting/nginx.customer_proxy_params",
      mode   => 0644,
      owner  => root,
      group  => root,
      notify => Service['nginx'];

    "/var/lib/hosting":
      ensure => directory,
      mode   => 0755,
      owner  => root,
      group  => root;

    "/etc/bind/hosting_zones":
      ensure  => directory,
      mode    => 0750,
      owner   => root,
      group   => bind,
      require => Class['bind::installation'];

    "/etc/ssl/www":
      ensure => directory,
      mode   => 0710,
      owner  => root,
      group  => www-data;
  }

  concat { "/etc/bind/named.conf.local":
    mode    => 644,
    owner   => root,
    group   => root,
    require => Class['bind::installation'],
    notify  => Class['bind::service'];
  }

  vcsrepo { "/var/lib/hosting/dasz-configuration":
    ensure   => present,
    revision => 'origin/master',
    provider => git,
    source   => "https://github.com/DavidS/dasz-configuration.git",
    owner    => root,
    group    => root,
    require  => Package['git'];
  }
}
