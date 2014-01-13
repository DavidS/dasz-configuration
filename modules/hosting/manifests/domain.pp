define hosting::domain ($customer, $all_customer_data) {
  include hosting

  $domain = $name
  $admin_user = $all_customer_data[$customer]['admin_user']
  $base_dir = "/srv/${customer}"
  $admin_group = "${customer}_admins"
  $app_user = "${customer}_app"
  $app_group = "${customer}_app"

  file {
    "${base_dir}/etc/nginx/sites-enabled/${domain}_others":
      content => template("hosting/nginx.default-site.erb"),
      replace => false,
      mode    => 0664,
      owner   => $admin_user,
      group   => $admin_group;

    "${base_dir}/etc/nginx/${domain}":
      ensure => directory,
      mode   => 02770,
      owner  => $admin_user,
      group  => $admin_group;

    "${base_dir}/www/${domain}":
      ensure => directory,
      mode   => 02770,
      owner  => $admin_user,
      group  => $admin_group;

    "${base_dir}/apps/${domain}.apps":
      content => template("hosting/apps.erb"),
      replace => false,
      mode    => 0664,
      owner   => $admin_user,
      group   => $admin_group;

    # add global configuration
    "/etc/nginx/sites-enabled/${domain}":
      content => template("hosting/nginx.frontend-site.erb"),
      notify  => Service['nginx'],
      mode    => 0644,
      owner   => root,
      group   => root;
  }

  # exim routing
  # according to config in /srv/${customer}/mail/${domain}

  # bind zone config
  # Needs to fetch data from somewhere (hash?)
}
