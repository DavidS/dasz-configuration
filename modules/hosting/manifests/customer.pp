# manages all resources for a single customer
#
# Files are usually confined to /srv/${name}
# Configuration goes to the respective daemons
#
# The admin user has full rights into everything
# The app user can read all "application" files and write to selected directories
# Normal users can only read and write their respective home directories
#
# type is a documentation flag
define hosting::customer ($admin_user, $admin_fullname, $type = 'none') {
  $customer = $name
  $base_dir = "/srv/${customer}"
  $admin_group = "${customer}_admins"
  $app_user = "${customer}_apps"
  $app_group = "${customer}_apps"

  group { [$admin_group, $app_group]: ensure => present }

  user {
    $admin_user:
      gid        => $admin_group,
      comment    => $admin_fullname,
      home       => "${base_dir}/home/${admin_user}",
      managehome => true;

    $app_user:
      gid        => $app_group,
      comment    => "${admin_fullname} (App)",
      home       => "${base_dir}/www",
      managehome => false,
  }

  file {
    [
      $base_dir,
      "${base_dir}/home"]:
      ensure => directory,
      mode   => 0751,
      owner  => root,
      group  => $admin_group;

    [
      "${base_dir}/home/${admin_user}",
      "${base_dir}/backups",
      "${base_dir}/mail",
      "${base_dir}/ssl",
      "${base_dir}/www",
      ]:
      ensure => directory,
      mode   => 2750,
      owner  => $admin_user,
      group  => $admin_group;
  }
}
