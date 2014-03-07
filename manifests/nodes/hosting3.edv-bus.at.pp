node 'hosting3.edv-bus.at' {
  class {
    'dasz::defaults':
      location    => hetzner,
      admin_users => false;

    'dasz::snips::systemd':
    ;

    'hosting':
      primary_fqdn          => 'hosting.edv-bus.at',
      primary_ns_name       => 'ns1.edv-bus.at',
      secondary_ns_name     => 'ns2.edv-bus.at',
      primary_mx_name       => $::fqdn,
      hosting_ipaddress     => $::ipaddress,
      hostmaster            => 'hostmaster.edv-bus.at',
      roundcube_db_password => file("/srv/puppet/secrets/${::fqdn}/roundcube_db.password"),
      webmail_vhost         => 'hosting.edv-bus.at',
      mailman_vhost         => 'hosting.edv-bus.at',
      sa_trusted_networks   => [$::ipaddress, '91.217.119.254'];

    'dasz::snips::adminmailer':
      recipient => 'root@dasz.at';
  }

  $customers = loadyaml("/srv/puppet/secrets/hosting/customers.yaml")
  create_resources("hosting::customer", $customers)
}
