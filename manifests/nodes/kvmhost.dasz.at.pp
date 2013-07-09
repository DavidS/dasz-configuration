node 'kvmhost.dasz.at' {
  class { 'dasz::defaults':
    location          => tech21,
    munin_smart_disks => ['sda', 'sdb'],
    force_nullmailer  => true;
  }
}