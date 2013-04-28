class dasz::defaults ($distro = $::lsbdistcodename, $location = 'unknown', $puppet_agent = true) {
  case $::virtual {
    'vserver' : {
      # only remove the package. See https://github.com/example42/puppet-ntp/issues/20
      include ntp::params

      package { $ntp::params::package: ensure => absent; }
    }
    default   : {
      class { "ntp": ; }
    }
  }

  class {
    "apt":
      force_sources_list_d => true;

    "openssh":
    ;

    "rsyslog":
    ;

    "sudo":
    ;
  }

  if $puppet_agent {
    class { "puppet":
      mode    => 'client',
      server  => 'puppetmaster.dasz.at', # can be configured more globally
      runmode => 'cron',
      require => Apt::Repository["puppetlabs"];
    }
  }

  package {
    [
      "vim",
      "lsb-release"]:
      ensure => installed;

    [
      "vim-tiny",
      "nano"]:
      ensure => absent;
  }

  apt::repository {
    "${distro}-base":
      url        => $location ? {
        'hetzner' => "http://mirror.hetzner.de/debian/packages",
        default   => 'http://http.debian.net/debian',
      },
      distro     => $distro,
      repository => "main",
      src_repo   => false,
      key        => "55BE302B";

    "${distro}-security":
      url        => "http://security.debian.org/",
      distro     => "${distro}/updates",
      repository => "main",
      src_repo   => false;

    "puppetlabs":
      url        => "http://apt.puppetlabs.com",
      distro     => $distro,
      repository => "main",
      src_repo   => false,
      key        => "4BD6EC30",
      key_url    => "https://apt.puppetlabs.com/pubkey.gpg";

    "puppetlabs-dependencies":
      url        => "http://apt.puppetlabs.com",
      distro     => $distro,
      repository => "dependencies",
      src_repo   => false,
      key        => "4BD6EC30",
      key_url    => "https://apt.puppetlabs.com/pubkey.gpg";
  }
}