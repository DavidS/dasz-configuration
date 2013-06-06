node 'hetz3.black.co.at' {
  class { 'dasz::defaults':
    location => hetzner,
    ssh_port => 2200;
  }

  # foreman virt host
  $home = '/var/lib/foreman-mgr'

  class { 'libvirt': }

  user { 'foreman-mgr':
    ensure     => present,
    system     => true,
    home       => $home,
    managehome => true,
    groups     => ['libvirt'],
    require    => Package['libvirt'];
  }

  file {
    "${home}/.ssh":
      ensure => directory,
      owner  => 'foreman-mgr',
      group  => 'foreman-mgr',
      mode   => 0700;

    "${home}/.ssh/authorized_keys":
      source => "puppet:///modules/site/foreman-authorized_keys",
      owner  => 'foreman-mgr',
      group  => 'foreman-mgr',
      mode   => 0600;
  }
}