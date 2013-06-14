class dasz::defaults (
  $distro               = $::lsbdistcodename,
  $location             = 'unknown',
  $puppet_agent         = true,
  $apt_dater_manager    = false,
  $apt_dater_key        = '',
  $apt_dater_secret_key = '',
  $ssh_port             = 22, # can be used on non-public sshds to reduce ssh bruteforce spamming, or avoid conflicts on shared IPs
  $admin_users          = true,) {
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
      ssh_port         => $ssh_port,
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
      port              => $ssh_port,
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

  # export a default host entry for apt-dater
  @@host { $::fqdn:
    host_aliases => [$hostname],
    ip           => $::ipaddress,
    tag          => 'dasz::default_host';
  }

  # collect host entries if we're a manager host
  if $apt_dater_manager {
    Host <<| tag == 'dasz::default_host' |>>
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

    "${distro}-backports":
      url        => $distro ? {
        'squeeze' => 'http://backports.debian.org/debian-backports/',
        default   => 'http://http.debian.net/debian',
      },
      distro     => "${distro}-backports",
      repository => "main",
      src_repo   => false;

    "${distro}-security":
      url        => "http://security.debian.org/",
      distro     => "${distro}/updates",
      repository => "main",
      src_repo   => false;
  }

  if $admin_users {
    dasz::snips::admin {
      "david":
        realname     => 'David Schmitt',
        ssh_key_type => 'ssh-rsa',
        ssh_key      => 'AAAAB3NzaC1yc2EAAAADAQABAAABAQC+PMJEejWaaoCHa46au1dBY+Atp53DSe4tSp28yFapd8/l40F9ENakp5V/58v+xMqQur1Wrj3xyFyavKMBSWedlezvUQKI4YMzH0VYJ0omrqkAKtZR/essZOBAHIB7fVXk4HHB6u5kNLXzGzESSiDDskmKTiN9ogQjWwCtdtk2DyooKMeA+nzWMmXoIOdUBxaZZkK12NT+LrMb8FyqhfUAHrpt2dK8L5xXnQ/xCFVbLgnsLe9aw/0qFtNndgw+0RuLm7jjetz7gYAQ4SpQAKiGC0wQLhB8ZLGKt/W+kCbdRO2WEjXzZxRAbjQyHao8gdCfHrflqy2rDm/ZXVikUwDV'
        ;

      'arthur':
        realname     => 'Arthur Zaczek',
        ssh_key_type => 'ssh-rsa',
        ssh_key      => 'AAAAB3NzaC1yc2EAAAABJQAAAQB2KUlinYZSvgqjkPUn62qkt8TIy+AbFOuuWMEf5sETWHoOA//RVmK4PkiAnAzdHKkWL0NdMAxkk5pl0guAuQtNZWrNaeqDtoiZX7+D1arPomykuurD27ceKkMgumhP/SHjV4cSvtSKif23X3y9x5mDkzHfewLjKypXBW58MlzhT7SRaMAmD4R1RTNrM4/0RpeiPB9t0wiCkE93ciqutFTm2h279CQnBGMoiV+hE5jloR18dGwByiGR7wpb2hOpmu6Q6CWotFaLWdUKO5TnqRWcOqkfA+H2Bb6wSjugOXek5N/Z7iWgM5IlITrBdLT7heroezLcuSbLtFHh8UVCIzQz';
    }
  }
}
