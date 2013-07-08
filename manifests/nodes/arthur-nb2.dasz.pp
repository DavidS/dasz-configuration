# windows pc
node 'arthur-nb2.dasz' {
  file {
    'C:\Program Files\OpenVPN\config\dasz.ovpn':
      ensure => present,
      content => template("site/arthur-nb2.dasz/dasz.ovpn.erb");

    'C:\Program Files\OpenVPN\config\ca.crt':
      ensure => present,
      source => "puppet:///secrets/openvpn/ca.crt";

    'C:\Program Files\OpenVPN\config\arthur-nb.key':
      ensure => present,
      source => "puppet:///secrets/openvpn/arthur-nb.key";

    'C:\Program Files\OpenVPN\config\arthur-nb.crt':
      ensure => present,
      source => "puppet:///modules/openvpn/arthur-nb.crt";
  }
}