# this class is reused between vagrants direct puppet provisioner and local puppet agent --test runs
# the latter are necessary to test storeconfigs
class puppetmaster_example_org {
  class {
    'dasz::defaults':
      puppet_agent         => false,
      apt_dater_manager    => true,
      apt_dater_key        => 'AAAAB3NzaC1yc2EAAAADAQABAAABAQCsg5F+Ml0AngmMMKrEr4YW5OP2qe2gpY9pfg0iFwjXnTqh8HZK63+HqmWGrGUt7mPZZMYOnGGkpYDmksqgHZscm6NGIxOvEWg52ZfcBUxIgKkoqZHIMSf/zhCifGxmepMHO/hb7wQKzwuc+XjzOwt70qwkhEDs6flKfYnagwxFC6YvrAeW5h2cwHDQb9To6ryITSvbhbUHNIwKGpYbz0Bqx5sdn2Kca80FsW8ImRmph4albnVMqDTdLCUvZoPhl/z6BCqduFpdPGGkfxicSmOBPRHuQOgTwTAh3aMR0lmnKfNX/wHqYgaWoU+ow+846ob70N949Oy05B/1Dc109Xfh',
      apt_dater_secret_key => template('site/puppetmaster/apt-dater-test-secret');

    "foreman":
      install_mode           => all,
      url                    => "https://${::fqdn}",
      puppet_server          => $::fqdn,
      authentication         => true,
      enc                    => true,
      reports                => true,
      facts                  => true,
      storeconfigs           => false,
      passenger              => true,
      unattended             => true,
      db                     => postgresql,
      db_server              => 'localhost',
      db_user                => 'foreman',
      db_password            => 'muhblah',
      # There currently is no working stable release (candidate) for wheezy
      repo_flavour           => nightly,
      install_proxy          => true,
      proxy_feature_puppet   => true,
      proxy_feature_puppetca => true,
      proxy_feature_tftp     => true;

    "postgresql":
    ;

    "puppet":
      template        => 'site/puppetmaster/puppet-vagrant.conf.erb',
      mode            => 'server',
      server          => 'puppetmaster.example.org', # can be configured more globally
      runmode         => 'manual', # change this later (to cron), see also croninterval, croncommand
      nodetool        => 'foreman',
      db              => 'puppetdb',
      db_server       => $::fqdn, # TODO: should be default?
      db_port         => 8081, # TODO: should be default for puppetdb?
      dns_alt_names   => '',
      autosign        => true,
      inventoryserver => '', # do not try to store facts anywhere
      # server_service_autorestart => true,
      require         => Class["dasz::defaults"];

    "puppetdb":
      db_type     => 'postgresql',
      db_host     => 'localhost',
      db_user     => 'puppetdb',
      db_password => 'muhblah', # local installation cannot depend on some secrets repo
      require     => [Host[$::fqdn], Class["dasz::defaults"]];
  }

  host {
    $::fqdn:
      host_aliases => [$::hostname, 'puppet', 'foreman'],
      ip           => $::ipaddress;

    'testagent.example.org':
      ip => '192.168.50.50';

    'workstation':
      ip => '192.168.50.1';
  }

  # workaround http://projects.theforeman.org/issues/2343
  file { "/usr/share/foreman/app/models/setting.rb":
    ensure  => present,
    source  => "puppet:///modules/site/foreman-app-models-setting.rb",
    mode    => 0644,
    owner   => foreman,
    group   => foreman,
    require => Package['foreman'],
    before  => Apache::Vhost['foreman'];
  }

  # required as apt-dater manager
  user { 'david': ensure => present; }
}

node 'puppetmaster.example.org' {
  include puppetmaster_example_org
}

# testagent in vagrant
# this can be used to test various stuff deployed via the puppetmaster
node 'testagent.example.org' {
  $testkey = 'OS/Yq8CnQ+XnsvwS783zCwHtTOtCuzPZhjM/sBZdTHTutLxxv/ahpPBOPPTrBWwSDeNL5BuW+IEcZF42c3V9WA=='

  class {
    'dasz::defaults':
      puppet_agent         => false,
      apt_dater_key        => 'AAAAB3NzaC1yc2EAAAADAQABAAABAQCsg5F+Ml0AngmMMKrEr4YW5OP2qe2gpY9pfg0iFwjXnTqh8HZK63+HqmWGrGUt7mPZZMYOnGGkpYDmksqgHZscm6NGIxOvEWg52ZfcBUxIgKkoqZHIMSf/zhCifGxmepMHO/hb7wQKzwuc+XjzOwt70qwkhEDs6flKfYnagwxFC6YvrAeW5h2cwHDQb9To6ryITSvbhbUHNIwKGpYbz0Bqx5sdn2Kca80FsW8ImRmph4albnVMqDTdLCUvZoPhl/z6BCqduFpdPGGkfxicSmOBPRHuQOgTwTAh3aMR0lmnKfNX/wHqYgaWoU+ow+846ob70N949Oy05B/1Dc109Xfh',
      apt_dater_secret_key => 'unused';

    "puppet":
      mode    => 'client',
      server  => 'puppetmaster.example.org',
      runmode => 'cron',
      require => Class['dasz::defaults'];

    "dhcpd":
      template => 'site/testagent/dhcpd.conf.erb';

    "foreman":
      install_mode         => 'none',
      install_proxy        => true,
      repo_flavour         => 'rc',
      proxy_feature_tftp   => true,
      proxy_feature_dhcp   => true,
      proxy_dhcp_omapi_key => $testkey;
  }
}

# my dev machine
# only used for stuff that has to run on bare metal
node 'david-lx1.dasz' {
  class { 'dasz::defaults':
    location     => hetzner,
    puppet_agent => false
  }
}