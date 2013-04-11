# This file is used for the initial puppet provisioning of the puppetmaster vbox

class {
  "apt":
    force_sources_list_d => true;

  "dasz::global":
    distro   => "wheezy",
    location => "global";

  "foreman":
    install_mode  => all,
    url           => "http://foreman",
    puppet_server => $::fqdn,
    enc           => true,
    reports       => true,
    facts         => true,
    storeconfigs  => false,
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
    require         => Class["dasz::global"];

  "puppetdb":
    db_type     => 'postgresql',
    db_host     => 'localhost',
    db_user     => 'puppetdb',
    db_password => 'muhblah', # local installation cannot depend on some secrets repo
    require     => [Host[$::fqdn], Class["dasz::global"]];

  "puppetdb::postgresql":
    require => Class["dasz::global"];

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

