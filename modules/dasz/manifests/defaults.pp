class dasz::defaults ($distro = $::lsbdistcodename, $location = 'unknown', $puppet_agent = true) {
  class {
    "apt":
      force_sources_list_d => true;

    "ntp":
    ;

    "openssh": # TODO: add host key management
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
      require => Apt::Repository["${distro}-puppetlabs"];
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

    "${distro}-puppetlabs":
      url        => "http://apt.puppetlabs.com",
      distro     => $distro,
      repository => "main",
      src_repo   => false,
      key        => "4BD6EC30",
      key_url    => "https://apt.puppetlabs.com/pubkey.gpg";
  }
}