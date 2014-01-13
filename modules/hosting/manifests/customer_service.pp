# manage an application service for a customer
define hosting::customer_service (
  $base_dir,
  $app_user,
  $admin_user,
  $admin_group,
  $service_name,
  $service_content    = undef,
  $service_source     = undef,
  $enable,
  $system_integration = true) {
  validate_bool($enable)
  $service_file_name = "${base_dir}/apps/.config/systemd/user/${service_name}.service"

  file { $service_file_name:
    ensure => present,
    #      replace => false,
    mode   => 0660,
    owner  => $admin_user,
    group  => $admin_group
  }

  if ($service_source != undef) {
    File[$service_file_name] {
      source => $service_source }
  }

  if ($service_content != undef) {
    File[$service_file_name] {
      content => $service_content }
  }

  if ($system_integration) {
    File[$service_file_name] {
      before => Service["user@${app_user}.service"] }
  }

  if ($enable) {
    $service_file = "${base_dir}/apps/.config/systemd/user/default.target.wants/${service_name}.service"

    file { $service_file:
      ensure => symlink,
      target => $service_file_name
    }

    if ($system_integration) {
      File[$service_file] {
        before => Service["user@${app_user}.service"] }
    }
  }
}
