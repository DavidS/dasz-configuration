define dasz::snips::admin ($realname, $ssh_key_type, $ssh_key, $shell = '/bin/bash', $home = '') {
  $real_home = $home ? {
    ''      => "/home/${name}",
    default => $home,
  }

  user { $name:
    ensure     => present,
    comment    => $realname,
    shell      => '/bin/bash',
    managehome => true,
    home       => $real_home;
  }

  sudo::directive { "${name}_is_admin": content => "${name} ALL=NOPASSWD: ALL"; }

  # potentially conflicts with apt::dater::manager
  if (!defined(File["${real_home}/.ssh"])) {
    file { "${real_home}/.ssh":
      ensure => directory,
      mode   => 0700,
      owner  => $name,
      group  => $name;
    }
  }

  file { "${real_home}/.ssh/authorized_keys":
    ensure => present,
    mode   => 0600,
    owner  => $name,
    group  => $name;
  }

  ssh_authorized_key { "${name}@puppet":
    user => $name,
    type => $ssh_key_type,
    key  => $ssh_key;
  }
}