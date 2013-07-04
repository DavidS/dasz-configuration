node 'proxy.dasz.at' {
  class { 'dasz::defaults':
    location         => hetzner,
    ssh_port         => 2201,
    munin_port       => 4951,
    force_nullmailer => true;
  }
}