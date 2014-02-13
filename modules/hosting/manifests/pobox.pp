define hosting::pobox ($uid = undef, $comment, $base_dir, $all_group, $groups = []) {
  group { $name: ; }

  user { $name:
    uid        => $uid,
    gid        => $name,
    comment    => $comment,
    home       => "${base_dir}/home/${name}",
    shell      => '/bin/bash',
    managehome => true,
    groups     => flatten([$name, $all_group, $groups]),
    require    => Group[$name];
  }
}
