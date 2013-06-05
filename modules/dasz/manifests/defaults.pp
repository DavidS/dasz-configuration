class dasz::defaults (
  $distro               = $::lsbdistcodename,
  $location             = 'unknown',
  $puppet_agent         = true,
  $apt_dater_manager    = false,
  $apt_dater_key        = '',
  $apt_dater_secret_key = '') {
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
      force_sources_list_d => true,
      purge_sources_list_d => true;

    "apt::dater":
      role             => $apt_dater_manager ? {
        true  => 'all',
        false => 'host',
      },
      customer         => $location,
      ssh_key_type     => $apt_dater_key ? {
        ''      => file("/srv/puppet/secrets/apt-dater-host.pub.type"),
        default => 'ssh-rsa',
      },
      ssh_key          => $apt_dater_key ? {
        ''      => file("/srv/puppet/secrets/apt-dater-host.pub.key"),
        default => $apt_dater_key,
      },
      manager_user     => 'david',
      manager_home_dir => '/home/david',
      manager_ssh_key  => $apt_dater_secret_key ? {
        ''      => file("/srv/puppet/secrets/apt-dater-host"),
        default => $apt_dater_secret_key,
      } ;

    "apt::repo::puppetlabs":
      distro       => $distro,
      dependencies => true;

    "dasz::snips::locales":
    ;

    "openssh":
      exchange_hostkeys => true;

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
  }
}
