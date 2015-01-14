class dasz::defaults (
  $distro               = $::lsbdistcodename,
  $location             = 'unknown',
  $puppet_agent         = true,
  $puppet_debug         = false,
  $primary_ip           = $::ipaddress,
  $munin_node           = true,
  $munin_port           = 4949,
  $munin_smart_disks    = [],
  $munin_server         = '',
  $apt_dater_manager    = false,
  $apt_dater_key        = '',
  $apt_dater_secret_key = '',
  $ssh_address          = '0.0.0.0',
  $ssh_port             = 22,
  # can be used on non-public sshds to reduce ssh bruteforce spamming, or avoid conflicts on shared IPs
  $admin_users          = true,
  $force_nullmailer     = false,
  $join_domain          = false) {
  validate_bool($puppet_agent)
  validate_bool($munin_node)
  validate_bool($apt_dater_manager)
  validate_bool($admin_users)
  validate_bool($force_nullmailer)
  validate_bool($join_domain)

  $real_munin_server = $munin_server? {
    '' => $location ? {
      'vagrant' => '192.168.50.5',
      'at'      => '10.0.0.217',
      'tech21'  => '10.0.0.217',
      'hetzner' => '10.0.0.217',
      default   => '88.198.141.234',
    },
    default => $munin_server,
  }

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

#    "apt::dater":
#      role             => $apt_dater_manager ? {
#        true  => 'all',
#        false => 'host',
#      },
#      customer         => $location,
#      ssh_key_type     => $apt_dater_key ? {
#        ''      => file("/srv/puppet/secrets/apt-dater-host.pub.type"),
#        default => 'ssh-rsa',
#      },
#      ssh_key          => $apt_dater_key ? {
#        ''      => file("/srv/puppet/secrets/apt-dater-host.pub.key"),
#        default => $apt_dater_key,
#      },
#      ssh_port         => $ssh_port,
#      manager_user     => 'david',
#      manager_home_dir => '/home/david',
#      manager_ssh_key  => $apt_dater_secret_key ? {
#        ''      => file("/srv/puppet/secrets/apt-dater-host"),
#        default => $apt_dater_secret_key,
#      } ;

    "apt::repo::puppetlabs":
      distro       => $distro,
      dependencies => true;

    "dasz::snips::locales":
    ;

    "openssh":
      port              => $ssh_port,
      template          => "openssh/sshd_config-${::lsbdistcodename}.erb",
      exchange_hostkeys => true,
      options           => {
        'ListenAddress' => $ssh_address
      };

    "rsyslog":
      template => 'dasz/rsyslog.conf.erb';

    "sudo":
    ;

    "timezone":
      timezone => 'Europe/Vienna';
  }

  if $force_nullmailer {
    class { "nullmailer":
      adminaddr   => 'root@dasz.at',
      remoterelay => 'hosting.edv-bus.at',
      remoteopts  => $::lsbdistcodename ? {
        'squeeze' => undef,
        default   => '--ssl'
      } ;
    }

    @@file { "/var/lib/puppet/modules/ssmtp/domains/${::fqdn}":
      ensure  => present,
      content => "root: root@dasz.at\nbackuppc: root@dasz.at\nnagios: root@dasz.at\njenkins: root@dasz.at\nmunin: root@dasz.at\n",
      mode    => 0644,
      owner   => root,
      group   => root,
      tag     => 'nullmailer_workaround';
    }

    munin::plugin { 'nullmailer_queue':
      source        => 'puppet:///modules/dasz/munin/nullmailer_queue',
      config_source => 'puppet:///modules/dasz/munin/nullmailer_queue.conf';
    }

    @@file { "/etc/exim4/adminmailer_domains/${::fqdn}":
      ensure => present,
      mode   => 0644,
      owner  => root,
      group  => root,
      tag    => 'dasz_snips_adminmailer';
    }
  }

  file {
    "/etc/profile.d/tf.sh":
      content => template('dasz/rsyslog.tf.sh.erb'),
      mode    => 0644,
      owner   => root,
      group   => root;

    "/etc/logrotate.d/rsyslog":
      content => template('dasz/rsyslog.logrotate.erb'),
      mode    => 0644,
      owner   => root,
      group   => root;

    "/etc/profile.d/home-bin.sh":
      content => template('dasz/home-bin.sh.erb'),
      mode    => 0644,
      owner   => root,
      group   => root;

    [
      "/root/bin",
      "/root/tmp"]:
      ensure => directory,
      mode   => 0755,
      owner  => root,
      group  => root;
  }

  if $puppet_agent {
    class { "puppet":
      mode            => 'client',
      server          => 'puppetmaster.dasz.at',
      # can be configured more globally
      runmode         => 'cron',
      croncommand     => $puppet_debug ? {
        true    => '/usr/bin/puppet agent --onetime --pidfile /var/run/puppet-cron.pid --verbose --debug',
        default => $puppet::params::croncommand,
      },
      prerun_command  => '/etc/puppet/etckeeper-commit-pre',
      postrun_command => '/etc/puppet/etckeeper-commit-post',
      require         => Apt::Repository["puppetlabs"];
    }

    file {
      '/etc/puppet/etckeeper-commit-pre':
        source => 'puppet:///modules/dasz/puppet/etckeeper-commit-pre',
        mode   => 0755,
        owner  => root,
        group  => root;

      '/etc/puppet/etckeeper-commit-post':
        source => 'puppet:///modules/dasz/puppet/etckeeper-commit-post',
        mode   => 0755,
        owner  => root,
        group  => root;
    }
  }

  if $munin_node {
    class { "munin":
      folder        => $location ? {
        'tech21'  => 'Tech21',
        'hetzner' => 'Hetzner',
        default   => $location,
      },
      server        => $real_munin_server,
      autoconfigure => once,
      address       => $primary_ip,
      port          => $munin_port,
      version       => $::lsbdistcodename ? {
        'squeeze' => '2.0.6-4+deb7u2~bpo60+1',
        default   => 'present',
      } ;
    }

    munin::plugin {
      # only works if testing and unstable sources are configured
      'apt':
        ensure => absent;

      'apt_all':
        path           => '/usr/share/munin/plugins/apt_all.fixed',
        source         => 'puppet:///modules/dasz/munin/apt_all.fixed',
        config_content => "[apt_all]\nuser root\nenv.releases ${distro}\n";
    }

    smart { $munin_smart_disks: }

    # remove non-rotated logfile
    file { "/var/log/munin/munin.log":
      ensure => absent,
      backup => false;
    }
  }

  # replace default cronjob to set proper environment vars in cronjob
  file { '/etc/cron.d/munin-node':
    ensure  => present,
    content => template('dasz/munin/munin-node.cron.erb'),
    mode    => '0644',
    owner   => root,
    group   => root;
  }

  # export a default host entry for apt-dater
  @@host { $::fqdn:
    host_aliases => [$hostname],
    ip           => $primary_ip,
    tag          => 'dasz::default_host';
  }

  # collect host entries if we're a manager host
  if $apt_dater_manager {
    Host <<| tag == 'dasz::default_host' |>>
  }

  dasz::nagios_host { $::fqdn: }

  package {
    [
      "vim",
      "lsb-release",
      "mmv",
      "strace",
      "lsof",
      "screen",
      "mtr-tiny",
      "etckeeper",
      "smartmontools",
      "popularity-contest",
      "bash-completion",
      "pwgen",
      "whois"]:
      ensure => installed;

    [
      "vim-tiny",
      "apt-listchanges"]:
      ensure => absent;
  }

  if (!defined(Package["dnsutils"])) {
    package { 'dnsutils': ensure => installed; }
  }

  file_line { 'popcon_http_only':
    path => '/etc/popularity-contest.conf',
    line => 'MAILTO=""';
  }

  $apt_key = $distro ? {
    'lenny'   => '55BE302B',
    'squeeze' => 'B98321F9',
    default   => '65FFB764', # wheezy
  }

  $default_apt_url = $location ? {
    'hetzner' => "http://mirror.hetzner.de/debian/packages",
    'tech21'  => "http://kvmhost.dasz:3142/debian",
    default   => 'http://http.debian.net/debian',
  }

  apt::repository { "${distro}-base":
    url        => $default_apt_url,
    distro     => $distro,
    repository => "main",
    src_repo   => false,
    key        => $apt_key;
  }

  # testing and unstable do not have backports or security repos
  if ($distro != 'jessie' and $distro != 'sid' and $distro != 'testing' and $distro != 'unstable') {
    apt::repository {
      "${distro}-updates":
        url        => $default_apt_url,
        distro     => "${distro}-updates",
        repository => "main",
        src_repo   => false;

      "${distro}-backports":
        url        => $distro ? {
          'squeeze' => 'http://backports.debian.org/debian-backports/',
          default   => $location ? {
            'tech21' => "http://kvmhost.dasz:3142/debian",
            default  => 'http://http.debian.net/debian',
          } },
        distro     => "${distro}-backports",
        repository => "main",
        src_repo   => false;

      "${distro}-security":
        url        => $location ? {
          'tech21' => "http://kvmhost.dasz:3142/security",
          default  => "http://security.debian.org/",
        },
        distro     => "${distro}/updates",
        repository => "main",
        src_repo   => false;
    }
  }

  if $admin_users {
    dasz::snips::admin {
      "david":
        realname     => 'David Schmitt',
        ssh_key_type => 'ssh-rsa',
        ssh_key      => 'AAAAB3NzaC1yc2EAAAADAQABAAABAQC6nfLnzeT4NmXy53/8ZCbvcbgZ496s5+o7ouIAhuNs7jzLBTSdXxJAxdDuX2RYJVL3AmcBkhrg2sL2dMnXrhP7KT/55z1vYFds80a6byWnFUKs/ZJAamEh+FfWkfbMe7MxdWn3qt832Kr6+t2/mxgZA+c0b4hHZuZy7VLw6O2hoLhrudOJV11GdMEebx9vNThj3NMsjtYOdaGiX8FgxpaI5JwahkuhCr/D6qSgu/GbWGuYc9r1O1QUy+lsuV8oe9LQdfT3j7dhLW1EsTNRzhsQJXKpfV0PPrYonNYQsyCoVEhP+2gqlnwEePeKaGYnxNYvqrWnXBs3j6sInwb0Btv/'
        ;

      'arthur':
        realname     => 'Arthur Zaczek',
        ssh_key_type => 'ssh-rsa',
        ssh_key      => 'AAAAB3NzaC1yc2EAAAABJQAAAQB2KUlinYZSvgqjkPUn62qkt8TIy+AbFOuuWMEf5sETWHoOA//RVmK4PkiAnAzdHKkWL0NdMAxkk5pl0guAuQtNZWrNaeqDtoiZX7+D1arPomykuurD27ceKkMgumhP/SHjV4cSvtSKif23X3y9x5mDkzHfewLjKypXBW58MlzhT7SRaMAmD4R1RTNrM4/0RpeiPB9t0wiCkE93ciqutFTm2h279CQnBGMoiV+hE5jloR18dGwByiGR7wpb2hOpmu6Q6CWotFaLWdUKO5TnqRWcOqkfA+H2Bb6wSjugOXek5N/Z7iWgM5IlITrBdLT7heroezLcuSbLtFHh8UVCIzQz'
        ;
    }
  }

  sudo::directive { "backuppc": content => 'abackup ALL=(ALL) NOPASSWD: /usr/bin/rsync --server --sender --numeric-ids --perms --owner --group --devices --links --times --block-size=2048 --recursive -D *'
    ; }

  if $::lsbdistcodename != 'squeeze' {
    package { "nocache": ensure => installed }
  }

  if $join_domain {
    package { ["libnss-winbind", "libpam-winbind"]: ensure => installed; } ->
    file {
      "/etc/samba/smb.conf":
        source => "puppet:///modules/dasz/samba.lan.dasz.at.conf",
        mode   => 0644,
        owner  => root,
        group  => root;

      "/etc/nsswitch.conf":
        source => "puppet:///modules/dasz/nsswitch.winbind.conf",
        mode   => 0644,
        owner  => root,
        group  => root;

      "/usr/share/pam-configs/mkhomedir":
        source => "puppet:///modules/dasz/pam.mkhomedir",
        mode   => 0644,
        owner  => root,
        group  => root,
        notify => Exec["/usr/sbin/pam-auth-update"];
    }

    exec { "/usr/sbin/pam-auth-update": refreshonly => true; }

    service { "winbind":
      ensure    => running,
      enable    => true,
      subscribe => [Package["libnss-winbind", "libpam-winbind"], File["/etc/samba/smb.conf"]]
    }
  }

  sshkey { 'github.com':
    type => 'ssh-rsa',
    key  => 'AAAAB3NzaC1yc2EAAAABIwAAAQEAq2A7hRGmdnm9tUDbO9IDSwBK6TbQa+PXYPCPy6rbTrTtw7PHkccKrpp0yVhp5HdEIcKr6pLlVDBfOLX9QUsyCOV0wzfjIJNlGEYsdlLJizHhbn2mUjvSAHQqZETYP81eFzLQNnPHt4EVVUh7VfDESU84KezmD5QlWpXLmvU31/yMf+Se8xhHTvKSCZIFImWwoG6mbUoWf9nzpIoaSjB+weqqUUmpaaasXVal72J+UX2B+2RPW3RcT0eOzQgqlJL3RKrTJvdsjE3JEAvGq3lGHSZXy28G3skua2SmVi/w4yCE6gbODqnTWlg7+wC604ydGXA8VJiS5ap43JXiUFFAaQ==',
  }
}

define smart () {
  munin::plugin { "smart_${name}":
    path          => '/usr/share/munin/plugins/smart_',
    manage_script => false;
  }
}
