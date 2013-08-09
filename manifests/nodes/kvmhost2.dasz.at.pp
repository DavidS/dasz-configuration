node 'kvmhost2.dasz.at' {
  class {
    'dasz::defaults':
      location          => tech21,
      ssh_address       => '10.0.0.192',
      munin_smart_disks => ['sda', 'sdb', 'sdc'],
      force_nullmailer  => true;

    'libvirt':
    ;
  }

  # foreman virt host
  $home = '/var/lib/foreman-mgr'

  user { 'foreman-mgr':
    ensure     => present,
    system     => true,
    home       => $home,
    managehome => true,
    groups     => ['libvirt'],
    require    => Package['libvirt'];
  }
}
