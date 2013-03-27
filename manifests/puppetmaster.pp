# This file is used for the initial puppet provisioning of the puppetmaster vbox

class {
  "apt":
    force_sources_list_d => true;

  "dasz::global":
  ;

  "foreman":
    install_mode  => all,
    url           => "http://foreman",
    puppet_server => $::fqdn,
    enc           => true,
    reports       => true,
    rubysitedir   => '/usr/lib/ruby/vendor_ruby',
    facts         => true,
    storeconfigs  => true,
    passenger     => true,
    db            => postgresql,
    db_server     => 'localhost',
    db_user       => 'foreman',
    db_password   => 'muhblah';

  "ntp":
  ;

  "openssh": # TODO: add host key management
  ;

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
    require         => Apt::Repository["wheezy-puppetlabs"];

  "puppetdb":
    db_type     => 'postgresql',
    db_host     => 'localhost',
    db_user     => 'puppetdb',
    db_password => 'muhblah', # local installation cannot depend on some secrets repo
    require     => [Host[$::fqdn], Apt::Repository["wheezy-puppetlabs"]];

  "puppetdb::postgresql":
    require => Apt::Repository["wheezy-puppetlabs"];

  "rsyslog":
  ;

  "sudo":
  ;
}

host {
  $::fqdn:
    host_aliases => [$::hostname, 'puppet', 'foreman'],
    ip           => $::ipaddress;

  'testagent.example.org':
    ip => '192.168.50.50';
}

apt::repository {
  "wheezy":
    url        => "http://http.debian.net/debian",
    distro     => "wheezy",
    repository => "main",
    src_repo   => false,
    key        => "55BE302B";

  "wheezy-security":
    url        => "http://security.debian.org/",
    distro     => "wheezy/updates",
    repository => "main",
    src_repo   => false;

  "wheezy-puppetlabs":
    url        => "http://apt.puppetlabs.com",
    distro     => "wheezy",
    repository => "main",
    src_repo   => false,
    key        => "4BD6EC30",
    key_url    => "https://apt.puppetlabs.com/pubkey.gpg";
}
