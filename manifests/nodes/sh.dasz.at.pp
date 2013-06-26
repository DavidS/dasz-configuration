node 'sh.dasz.at' {
  class { 'dasz::defaults':
    location   => hetzner,
    munin_port => 5889;
  }
}
