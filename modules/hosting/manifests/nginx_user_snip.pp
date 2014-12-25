# some resources here have to be defined()-protected since they can be shared between
# multiple snips
define hosting::nginx_user_snip (
  $admin_user,
  $customer,
  $subdomain       = '',
  $basedomain,
  $url_path,
  $type,
  $destination,
  $forcessl        = false,
  $in_user_context = false,) {
  validate_re($type, 'static|cgi|php5|mono|redirect|php5-wordpress|php5-owncloud')
  validate_bool($forcessl)

  $domain = $subdomain ? {
    ''      => $basedomain,
    default => "${subdomain}.${basedomain}"
  }
  $base_dir = "/srv/${customer}"
  $admin_group = "${customer}_admins"

  $url_path_as_filename = inline_template("<%= @url_path.gsub(/[^a-zA-Z0-9]/, '_') %>")
  $nginx_config_dir = "${base_dir}/etc/nginx/${domain}"
  $nginx_domain_config = "${base_dir}/etc/nginx/sites-enabled/50-${domain}.conf"

  if ($forcessl) {
    fail("forcessl: not yet implemented")
  }

  if (!defined(File[$nginx_config_dir])) {
    file { $nginx_config_dir:
      ensure => directory,
      mode   => 02770,
      owner  => $admin_user,
      group  => $admin_group;
    }
  }

  if (!defined(File[$nginx_domain_config])) {
    file { $nginx_domain_config:
      ensure  => present,
      content => template("hosting/nginx.app-site.conf.erb"),
      mode    => 0664,
      owner   => $admin_user,
      group   => $admin_group;
    }
  }

  case $type {
    'mono'     : {
      # configure proxy pass through
      $nginx_config_content = template("hosting/nginx.mono-proxy.conf.erb")

      # configure fastcgi-mono-server4 instance
      if (!defined(Hosting::Customer_service["${customer}::${destination}"])) {
        hosting::customer_service { "${customer}::${destination}":
          base_dir        => $base_dir,
          admin_user      => $admin_user,
          admin_group     => $admin_group,
          service_name    => $destination,
          service_content => template("hosting/mono-fcgi.service.erb"),
          enable          => true,
          in_user_context => $in_user_context,
        }

        file { "${base_dir}/etc/mono-${destination}":
          ensure => directory,
          mode   => 0770,
          owner  => $admin_user,
          group  => $admin_group;
        }
      }

      file { "${base_dir}/etc/mono-${destination}/${domain}.${url_path_as_filename}.webapp":
        content => template('hosting/mono.webapp.erb'),
        mode    => 0660,
        owner   => $admin_user,
        group   => $admin_group;
      }
    }
    /^php5/    : {
      # configure proxy pass through
      $nginx_config_content = template("hosting/nginx.${type}-proxy.conf.erb")

      # configure php5-fcgi/fpm instance
      if (!defined(Hosting::Customer_service["${customer}::${destination}"])) {
        hosting::customer_service { "${customer}::${destination}":
          base_dir        => $base_dir,
          admin_user      => $admin_user,
          admin_group     => $admin_group,
          service_name    => $destination,
          service_content => template("hosting/php5-fpm.service.erb"),
          enable          => true,
          in_user_context => $in_user_context,
        }

        file {
          "${base_dir}/etc/php5-${destination}":
            ensure => directory,
            mode   => 0750,
            owner  => $admin_user,
            group  => $admin_group;

          "${base_dir}/etc/php5-${destination}/php-fpm.conf":
            content => template("hosting/php5-fpm.conf.erb"),
            mode    => 0640,
            owner   => $admin_user,
            group   => $admin_group;
        }
      }
    }
    'redirect' : {
      $nginx_config_content = template("hosting/nginx.user-redirect.conf.erb")
    }
    'static'   : {
      $nginx_config_content = template("hosting/nginx.user-static.conf.erb")
    }
  }

  # configure nginx with chosen content
  file { "${nginx_config_dir}/${url_path_as_filename}.conf":
    content => $nginx_config_content,
    mode    => 0660,
    owner   => $admin_user,
    group   => $admin_group;
  # TODO: notify/restart nginx user instance
  }
}
