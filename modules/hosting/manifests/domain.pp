define hosting::domain ($customer, $all_customer_data) {
  include hosting

  $domain = $name
  $admin_user = $all_customer_data[$customer]['admin_user']
  $base_dir = "/srv/${customer}"
  $admin_group = "${customer}_admins"
  $app_user = "${customer}_app"
  $app_group = "${customer}_app"

  file {
    "${base_dir}/etc/nginx/sites-enabled/${domain}":
      content => template("hosting/nginx.default-site.erb"),
      mode    => 0664,
      #      replace => false,
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
      mode    => 0664,
      #      replace => false,
      owner   => $admin_user,
      group   => $admin_group;

    # add global configuration
    "/etc/nginx/sites-enabled/${domain}":
      content => template("hosting/nginx.frontend-site.erb"),
      notify  => Service['nginx'];
  }

  # #TODO: add services
  # nginx
  # See http://publications.jbfavre.org/web/nginx-vhosts-automatiques-avec-SSL-et-authentification.en
  # this can also be used to replace vhosts with app sockets
  # if (-e /srv/${customer}/www/${domain}/${app_subdomain}.socket) { ... }

  # php-fpm
  # default service for files

  # exim routing
  # according to config in /srv/${customer}/mail/${domain}

  # bind zone config
  # Needs to fetch data from somewhere (hash?)
}
