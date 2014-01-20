define hosting::pobox ($uid = undef, $gid, $comment, $base_dir, $all_group, $groups = []) {
  user { $name:
    uid        => $uid,
    gid        => $gid,
    comment    => $comment,
    home       => "${base_dir}/home/${name}",
    shell      => '/bin/bash',
    managehome => true,
    groups     => flatten([$all_group, $groups]);
  }
}