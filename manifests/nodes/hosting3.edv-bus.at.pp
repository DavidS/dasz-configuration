node 'hosting3.edv-bus.at' {
  class {
    'dasz::defaults':
      location    => hetzner,
      admin_users => false,
      ssh_port    => 2200; # do not collide with hosting ssh



    'dasz::snips::systemd':
    ;

    'hosting':
      primary_fqdn          => 'hosting.edv-bus.at',
      primary_ns_name       => 'ns1.edv-bus.at',
      secondary_ns_name     => 'ns2.edv-bus.at',
      primary_mx_name       => 'mail.edv-bus.at',
      hosting_ipaddress     => $::ipaddress,
      hostmaster            => 'hostmaster.edv-bus.at',
      roundcube_db_password => file("/srv/puppet/secrets/${::fqdn}/roundcube_db.password");
  }

  $customers = loadyaml("/srv/puppet/secrets/hosting/customers.yaml")
  create_resources("hosting::customer", $customers)
}
