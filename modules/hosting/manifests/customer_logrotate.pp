define hosting::customer_logrotate(
  $base_dir,
  $admin_user,
  $admin_group,
  $service,
  $log_file,
  )
{
  file {
    "/etc/logrotate.d/hosting_${name}.conf":
      content => template("hosting/customer.logrotate.conf.erb"),
      mode    => 0644,
      owner   => root,
      group   => root;
  }
}
