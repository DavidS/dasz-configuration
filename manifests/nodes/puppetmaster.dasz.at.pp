node 'puppetmaster.dasz.at' {
  $proxy_key = file("/srv/puppet/secrets/${::fqdn}/proxy_key.key")

  class {
    'dasz::defaults':
      location          => hetzner,
      puppet_agent      => false,
      apt_dater_manager => true;

    "dhcpd":
      template => "site/${::fqdn}/dhcpd.conf.erb";

    "foreman":
      install_mode           => all,
      url                    => "https://${::fqdn}",
      puppet_server          => $::fqdn,
      authentication         => true,
      enc                    => true,
      reports                => true,
      rubysitedir            => '/usr/lib/ruby/vendor_ruby',
      facts                  => true,
      storeconfigs           => false,
      passenger              => true,
      db                     => postgresql,
      db_server              => 'localhost',
      db_user                => 'foreman',
      db_password            => file("/srv/puppet/secrets/${::fqdn}/foreman.password"),
      unattended             => true,
      # There currently is no working stable release (candidate) for wheezy
      repo_flavour           => nightly,
      install_proxy          => true,
      proxy_feature_puppet   => true,
      proxy_feature_puppetca => true,
      proxy_feature_tftp     => true,
      # force foreman to use the private ip for tftp
      proxy_tftp_servername  => '192.168.5.2',
      proxy_feature_dhcp     => true,
      proxy_dhcp_omapi_key   => $proxy_key;

    "postgresql":
    ;

    "puppet":
      template            => 'site/puppetmaster/puppet.conf.erb',
      template_fileserver => 'site/puppetmaster/fileserver.conf.erb',
      allow               => ['*.dasz.at', '*.dasz', '*.black.co.at', '*.edv-bus.at', '127.0.0.1'],
      mode                => 'server',
      server              => 'puppetmaster.dasz.at', # can be configured more globally
      runmode             => 'cron',
      nodetool            => 'foreman',
      db                  => 'puppetdb',
      db_server           => $fqdn, # TODO: should be default?
      db_port             => 8081, # TODO: should be default for puppetdb?
      dns_alt_names       => '',
      autosign            => false, # do not autosign on publicly accessible masters
      inventoryserver     => '', # do not try to store facts anywhere
      # server_service_autorestart => true,
      require             => Class["dasz::defaults"];

    "puppetdb":
      db_type     => 'postgresql',
      db_host     => 'localhost',
      db_user     => 'puppetdb',
      db_password => file("/srv/puppet/secrets/${::fqdn}/puppetdb.password"),
      require     => [Host[$::fqdn], Class["dasz::defaults"]];
  }

  sudo::directive { "admin-users":
    ensure  => present,
    content => "david ALL=(ALL) NOPASSWD: ALL\n"
  }

  group { 'david': ensure => present; }

  user { 'david':
    ensure => present,
    gid    => 'david';
  }

  # of course, the following is not bootstrappable, but after a manual intervention, it should lead to a stable, and migratable
  # situation.
  # for a key roll-over, the git server has to accept both the old and the new key until the puppetmaster has updated itself.
  vcsrepo { "/srv/puppet/secrets":
    ensure   => latest,
    provider => git,
    source   => "ssh://ccnet@dasz.at/srv/dasz/git/puppet-secrets.git",
    owner    => puppet,
    group    => puppet;
  } -> file {
    # vcsrepo does not manage the rights on the directory, so we have to.
    # this leaves a little window of opportunity where the secrets are accessible, after
    # cloning the repository. Since this should only happen when the puppetmaster is
    # re-imaged, I do not believe this to be a problem.
    "/srv/puppet/secrets":
      ensure => directory,
      mode   => 0700,
      owner  => puppet,
      group  => puppet;

    "/root/.ssh":
      ensure => directory,
      mode   => 0700,
      owner  => root,
      group  => root;

    "/root/.ssh/id_rsa":
      source => "puppet:///secrets/id_rsa",
      mode   => 0600,
      owner  => root,
      group  => root;

    "/usr/share/foreman/.ssh":
      ensure => directory,
      mode   => 0700,
      owner  => foreman,
      group  => foreman;

    "/usr/share/foreman/.ssh/id_rsa":
      source => "puppet:///secrets/foreman/id_rsa",
      mode   => 0600,
      owner  => foreman,
      group  => foreman;
  }
}
