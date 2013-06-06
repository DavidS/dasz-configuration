node 'proxy.dasz.at' {
  class { 'dasz::defaults':
    location => hetzner,
    ssh_port => 2201;
  }
}