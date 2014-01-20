node 'hosting3.edv-bus.at' {
  class {
    'dasz::defaults':
      location    => hetzner,
      admin_users => false,
      ssh_port    => 2200; # do not collide with hosting ssh



    'dasz::snips::systemd':
    ;
  }

  $customers = loadyaml("/srv/puppet/secrets/hosting/customers.yaml")
  create_resources("hosting::customer", $customers)
}
