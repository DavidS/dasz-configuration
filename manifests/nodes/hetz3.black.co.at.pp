node 'hetz3.black.co.at' {
  class { 'dasz::defaults': location => hetzner; }

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
      mode   => 0700;

    "${home}/.ssh/authorized_keys":
      content => "puppet:///secrets/foreman_keys",
      owner   => 'foreman-mgr',
      mode    => 0600;
  }
}