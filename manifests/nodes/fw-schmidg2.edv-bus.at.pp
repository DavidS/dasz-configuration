node 'fw-schmidg2.edv-bus.at' {
  class { 'dasz::defaults':
    location          => 'Schmidg',
    primary_ip        => '192.168.0.2', # only reachable via ovpn-maria
    munin_smart_disks => ['sda'],
    force_nullmailer  => true;
  }
}