# manages all resources for a single customer
# Files are usually confined to /srv/${name}
# Configuration goes to the respective daemons
# The main user has full rights into everything
# The app user can read all "application" files and write to selected directories
# Normal users can only read and write their respective home directories
# Type is a documentation flag
define hosting::customer ($admin_user, $admin_fullname, $type = 'none') {
  $base_dir = "/srv/${name}"
  $admin_group = "${name}_admins"
  $app_user = "${name}_apps"

  group { $admin_group: ensure => present }

  user { $admin_user:
    gid        => $admin_group,
    comment    => $admin_fullname,
    home       => "${base_dir}/home/${admin_user}",
    managehome => true,
  }

  file {
    [
      $base_dir,
      "${base_dir}/home"]:
      ensure => directory,
      mode   => 0751,
      owner  => root,
      group  => $admin_group;

    "${base_dir}/home/${admin_user}":
      ensure => directory,
      mode   => 2750,
      owner  => $admin_user,
      group  => $admin_group;
  }
}
