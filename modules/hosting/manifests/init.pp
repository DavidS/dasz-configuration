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
class hosting {
  include nginx

  # use mono3
  apt::repository { "zetbox":
    url        => "http://kvmhost.dasz/debian",
    distro     => zetbox,
    repository => "main";
  }

  package { ["mono-complete", "mono-fastcgi-server"]: ensure => installed; }

  # import certificates from mozilla
  exec { "/usr/bin/mozroots --import --sync":
    refreshonly => true,
    subscribe   => Package['mono-complete'];
  }

  exec { 'systemd-reload':
    command     => '/bin/systemctl --system daemon-reload',
    refreshonly => true;
  }

  file {
    "/etc/nginx/php5-fpm_params":
      source  => "puppet:///modules/hosting/nginx.php5-fpm_params",
      mode    => 0644,
      owner   => root,
      group   => root,
      require => Class['nginx'];

    "/var/lib/hosting":
      ensure => directory,
      mode   => 0755,
      owner  => root,
      group  => root;
  }

  vcsrepo { "/var/lib/hosting/dasz-configuration":
    ensure   => latest,
    provider => git,
    source   => "https://github.com/DavidS/dasz-configuration.git",
    owner    => root,
    group    => root;
  }
}
