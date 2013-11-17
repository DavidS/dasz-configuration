
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

    # the crl needs to be accessible to the running openvpn daemon, so we copy it out of the sealed keys directory.
    "/etc/openvpn/${name}-ca/crl.pem":
      ensure => present,
      source => "/etc/openvpn/${name}-ca/keys/crl.pem",
      mode   => '0644',
      owner  => root,
      group  => root,
      notify => Class['openvpn'];
  }
}