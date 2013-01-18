
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

  # of course, the following is not botstrappable, but after a manual intervention, it should lead to a stable, and migratable
  # situation.
  # for a key roll-over, the git server has to accept both the old and the new key until the puppetmaster has updated itself.
  vcsrepo { "/srv/puppet/secrets":
    ensure   => latest,
    provider => git,
    source   => "ssh://ccnet@dasz.at/srv/dasz/git/puppet-secrets.git",
    owner    => root,
    group    => root;
  } -> file {
    # vcsrepo does not manage the rights on the directory, so we have to.
    # this leaves a little window of opportunity where the secrets are accessible, after
    # cloning the repository. Since this should only happen when the puppetmaster is
    # re-imaged, I do not believe this to be a problem.
    "/srv/puppet/secrets":
      ensure => directory,
      mode   => 0700,
      owner  => root,
      group  => root;

    "/root/.ssh":
      ensure => directory,
      mode   => 0700,
      owner  => root,
      group  => root;

    "/root/.ssh/id_rsa":
      source => "/srv/puppet/secrets/puppetmaster/id_rsa",
      mode   => 0600,
      owner  => root,
      group  => root;
  }

  # for documentation purposes only.
  # in production, this will be replaced by a git-hook-pushed mirror
  vcsrepo { "/srv/puppet/configuration":
    ensure   => latest,
    provider => git,
    source   => "git://github.com/DavidS/dasz-configuration.git",
    owner    => root,
    group    => root;
  }
}
