define hosting::domain ($admin_user, $base_dir, $admin_group, $app_user) {
  include hosting

  $domain = $name

  file {
    "${base_dir}/etc/nginx/sites-enabled/99-${domain}_others.conf":
      content => template("hosting/nginx.default-site.erb"),
      replace => false,
      mode    => 0664,
      owner   => $admin_user,
      group   => $admin_group;

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
    "/etc/nginx/sites-enabled/99-${domain}.conf":
      content => template("hosting/nginx.frontend-site.erb"),
      mode    => 0644,
      owner   => root,
      group   => root,
      require => Package['nginx'],
      notify  => Service['nginx'];
  }

  # avoid overlap with nginx_user_snip
  if (!defined(File["${base_dir}/etc/nginx/${domain}"])) {
    file { "${base_dir}/etc/nginx/${domain}":
      ensure => directory,
      mode   => 02770,
      owner  => $admin_user,
      group  => $admin_group;
    }
  }

  # exim routing
  # according to config in /srv/${customer}/mail/${domain}

  # bind zone config
  # Needs to fetch data from somewhere (hash?)
}
