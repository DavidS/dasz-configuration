
node 'puppetmaster.dasz.at' {
  class { 'sudo': }

  group { 'david': ensure => present; }

  user { 'david':
    ensure => present,
    gid    => 'david';
  }

  sudo::conf { "admin-users":
    ensure  => present,
    content => "david ALL=(ALL) NOPASSWD: ALL\n"
  }

  file { "/etc/apt/sources.list": ensure => absent; } ~> apt::source {
    "wheezy-hetzner":
      location          => "http://mirror.hetzner.de/debian/packages",
      release           => "wheezy",
      repos             => "main",
      include_src       => false,
      required_packages => "debian-archive-keyring",
      key               => "55BE302B",
      key_server        => "subkeys.pgp.net";

    "wheezy-security":
      location          => "http://security.debian.org/",
      release           => "wheezy/updates",
      repos             => "main",
      include_src       => false,
      required_packages => "debian-archive-keyring",
      key               => "55BE302B",
      key_server        => "subkeys.pgp.net";
  }
}

