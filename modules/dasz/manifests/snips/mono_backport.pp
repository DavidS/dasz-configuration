class dasz::snips::mono_backport () {
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

  package { ["mono-complete", "mono-fastcgi-server",]: ensure => installed; } ->
  # mono's npgsql is so old, nobody can work with it
  exec { "ungac npgsql":
    command => "/usr/bin/gacutil -u Npgsql",
    unless  => "/usr/bin/test $(/usr/bin/gacutil -l Npgsql | wc -l) -eq 2"
  }
}
