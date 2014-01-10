define hosting::nginx_user_snip ($domain, $customer, $admin_user, $type, $local_name, $location, $flags = '') {
  validate_re($type, 'static|php5|mono|redirect')
  $base_dir = "/srv/${customer}"
  $admin_group = "${customer}_admins"
  $app_user = "${customer}_app"
  $location_as_filename = inline_template("<%= @location.gsub('[^a-zA-Z0-9]', '_') %>")

  case $type {
    'mono'     : {
      # configure fastcgi-mono-server4 instance
      hosting::customer_service { "${customer}::${local_name}":
        base_dir        => $base_dir,
        app_user        => $app_user,
        admin_user      => $admin_user,
        admin_group     => $admin_group,
        service_name    => $local_name,
        service_content => template("hosting/mono-fcgi.service.erb"),
        enable          => true,
      }
      # configure proxy pass through
      $nginx_config_content = template("hosting/nginx.mono-proxy.conf.erb")
    }
    'php5'     : { # configure php5-fcgi/fpm instance
                   # configure proxy pass through
    }
    'redirect' : {
      $nginx_config_content = template("hosting/nginx.user-redirect.conf.erb")
    }
    'static'   : {
      $nginx_config_content = template("hosting/nginx.user-static.conf.erb")
    }
  }

  # configure nginx with chosen content
  file { "${base_dir}/etc/nginx/${domain}/${location_as_filename}.conf":
    content => $nginx_config_content,
    mode    => 0660,
    owner   => $admin_user,
    group   => $admin_group;
  # TODO: notify/restart nginx user instance
  }
}