define hosting::pobox ($uid = undef, $comment, $base_dir, $all_group, $admin = false, $admin_user, $admin_group, $groups = []) {
  $normal_groups = [$name, $all_group, $groups]
  $admin_groups = [$name, $all_group, $admin_group, $groups]
  $home = "${base_dir}/home/${name}"

  group { $name: ensure => present; }

  user { $name:
    ensure     => present,
    uid        => $uid,
    gid        => $name,
    comment    => $comment,
    home       => $home,
    shell      => '/bin/bash',
    managehome => true,
    groups     => flatten($admin ? {
      true  => $admin_groups,
      false => $normal_groups
    } ),
    require    => Group[$name];
  }

  if $admin {
    file {
      "${home}/bin":
        ensure => directory,
        owner  => $name,
        group  => $name;

      "${home}/bin/systemctl_hosting":
        content => template("hosting/systemctl_hosting.erb"),
        mode    => 0755,
        owner   => $name,
        group   => $name;
    }

    sudo::directive { "${name}_is_customer_admin":
      order   => 30,
      content => "${name} ALL=(root) NOPASSWD: /bin/su - ${admin_user} -c systemctl --user *";
    }
  }
}
