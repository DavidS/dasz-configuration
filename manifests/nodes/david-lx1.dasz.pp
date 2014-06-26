node 'david-lx1.dasz' {
  class {
    'dasz::defaults':
      location          => at,
      apt_dater_manager => true,
      munin_smart_disks => ['sda', 'sdb'],
      force_nullmailer  => true;

    'libvirt':
    ;
  }

  file {
    "/etc/dhcp/dhclient.conf":
      ensure  => present,
      content => template("site/${::fqdn}/dhclient.conf.erb");

    "/etc/openvpn/dasz_up":
      ensure  => present,
      content => template("site/${::fqdn}/dasz_up.erb"),
      mode    => 0755,
      owner   => root,
      group   => root,
      notify  => Service['openvpn'];

    "/etc/openvpn/dasz_down":
      ensure  => present,
      content => template("site/${::fqdn}/dasz_down.erb"),
      mode    => 0755,
      owner   => root,
      group   => root,
      notify  => Service['openvpn'];
  }

#  apt::repository {
#    "zetbox":
#      url        => "http://kvmhost.dasz/debian",
#      distro     => zetbox,
#      repository => "main";
#
#    "sid-sources":
#      url        => "http://kvmhost.dasz:3142/debian",
#      distro     => sid,
#      repository => "main",
#      src_repo   => true;
#  }
}
