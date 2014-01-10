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
  #  file { "/lib/systemd/system-generators/hosting-apps-generator":
  #    source => 'puppet:///modules/hosting/hosting-apps-generator',
  #    mode   => 0755,
  #    owner  => root,
  #    group  => root,
  #    notify => Exec['systemd-reload'];
  #  }
  #
  #  file {
  #    "/etc/systemd/user/dbus.socket":
  #      source => 'puppet:///modules/hosting/dbus.socket',
  #      mode   => 0644,
  #      owner  => root,
  #      group  => root,
  #      notify => Exec['systemd-reload'];
  #
  #    "/etc/systemd/user/dbus.service":
  #      source => 'puppet:///modules/hosting/dbus.service',
  #      mode   => 0644,
  #      owner  => root,
  #      group  => root,
  #      notify => Exec['systemd-reload'];
  #  }

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
}
