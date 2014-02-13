# manage an application service for a customer
define hosting::customer_service (
  $base_dir,
  $admin_user,
  $admin_group,
  $service_name,
  $service_content    = undef,
  $service_source     = undef,
  $enable,
  $system_integration = true) {
  validate_bool($enable)
  $service_name_escaped = inline_template('<%= @service_name.gsub(/-/, "\\x2d").gsub(/\//, "-").gsub(/^-|-$/, "") %>')
  $service_file_name = "${base_dir}/home/${admin_user}/.config/systemd/user/${service_name_escaped}.service"
  $admin_user_escaped = inline_template('<%= @admin_user.gsub(/-/, "\\x2d").gsub(/\//, "-").gsub(/^-|-$/, "") %>')

  file { $service_file_name:
    ensure  => present,
    replace => false,
    mode    => 0660,
    owner   => $admin_user,
    group   => $admin_group
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
      before => Service["user@${admin_user_escaped}.service"] }
  }

  if ($enable) {
    $service_file = "${base_dir}/home/${admin_user}/.config/systemd/user/default.target.wants/${service_name_escaped}.service"

    file { $service_file:
      ensure => symlink,
      target => $service_file_name
    }

    if ($system_integration) {
      File[$service_file] {
        before => Service["user@${admin_user_escaped}.service"] }
    }
  }
}
