define hosting::domain ($customer, $all_customer_data) {
  $domain = $name
  $admin_user = $all_customer_data[$customer]['admin_user']
  $base_dir = "/srv/${customer}"
  $admin_group = "${customer}_admins"
  $app_user = "${customer}_apps"
  $app_group = "${customer}_apps"

  file { "${base_dir}/www/${domain}":
    ensure => directory,
    mode   => 02770,
    owner  => $admin_user,
    group  => $admin_group;
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