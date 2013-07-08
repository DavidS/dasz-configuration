
define site::ovpn_keys () {
  file {
    "/etc/openvpn/${name}-ca":
      ensure => directory,
      mode   => '0700',
      owner  => root,
      group  => root,
      notify => Class['openvpn'];

    "/etc/openvpn/${name}-ca/keys":
      ensure  => directory,
      mode    => '0700',
      owner   => root,
      group   => root,
      source  => "puppet:///secrets/openvpn_ca/${name}-ca/keys",
      ignore  => ['*.key', '*.csr'],
      recurse => true,
      force   => true,
      purge   => true,
      notify  => Class['openvpn'];

    "/etc/openvpn/${name}-ca/keys/${::fqdn}.key":
      ensure => directory,
      mode   => '0600',
      owner  => root,
      group  => root,
      source => "puppet:///secrets/openvpn_ca/${name}-ca/keys/${::fqdn}.key",
      notify => Class['openvpn'];
  }
}