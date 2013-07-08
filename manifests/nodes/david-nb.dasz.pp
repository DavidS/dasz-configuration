# windows pc
node 'david-nb.dasz' {
  file {
    'C:\Program Files\OpenVPN\config\dasz.ovpn':
      ensure => present,
      content => template("site/david-nb.dasz/dasz.ovpn.erb");

    'C:\Program Files\OpenVPN\config\ca.crt':
      ensure => present,
      source => "puppet:///secrets/openvpn/ca.crt";

    'C:\Program Files\OpenVPN\config\arthur-nb.key':
      ensure => present,
      source => "puppet:///secrets/openvpn/arthur-nb.key";

    'C:\Program Files\OpenVPN\config\arthur-nb.crt':
      ensure => present,
      source => "puppet:///secrets/openvpn/arthur-nb.crt";
  }
}