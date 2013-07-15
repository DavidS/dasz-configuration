node 'hosting3.edv-bus.at' {
  class {
    'dasz::defaults':
      location => hetzner,
      ssh_port => 2200; # do not collide with hosting ssh

    'dasz::snips::systemd':
    ;
  }
}
