node 'hosting3.edv-bus.at' {
  class {
    'dasz::defaults':
      location => hetzner,
      ssh_port => 2200; # do not collide with hosting ssh



    'dasz::snips::systemd':
    ;
  }

  create_resources("hosting::customer", loadyaml("/srv/puppet/secrets/hosting/customers.yaml"))
  create_resources("hosting::domain", loadyaml("/srv/puppet/secrets/hosting/domains.yaml"))
}
