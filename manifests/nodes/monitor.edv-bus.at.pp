node 'monitor.edv-bus.at' {
  class { 'dasz::defaults':
    location => hetzner,
    ssh_port => 2200;
  }
}