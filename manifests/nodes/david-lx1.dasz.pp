node 'david-lx1.dasz' {
  class { 'dasz::defaults':
    location          => tech21,
    apt_dater_manager => true,
    munin_smart_disks => ['sda', 'sdb'],
    force_nullmailer  => true;
  }
}