node 'fw-maria.mariatreu.at' {
  class { 'dasz::defaults':
    location          => 'Schmidg',
    primary_ip        => '192.168.0.131', # only reachable via ovpn-maria
    munin_smart_disks => ['sda'],
    force_nullmailer  => true;
  }
}
