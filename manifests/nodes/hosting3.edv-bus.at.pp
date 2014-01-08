# placeholder
define hosting::customer ($type) {
  file { "/data/srv/${name}":
    ensure => directory,
    noop   => true;
  }
}

node 'hosting3.edv-bus.at' {
  class {
    'dasz::defaults':
      location => hetzner,
      ssh_port => 2200; # do not collide with hosting ssh



    'dasz::snips::systemd':
    ;
  }

  create_resources("hosting::customer", loadyaml("/srv/puppet/secrets/hosting/customers.yaml"))
}
