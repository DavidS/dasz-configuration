# some resources here have to be defined()-protected since they can be shared between
# multiple snips
define hosting::nginx_user_snip (
  $basedomain,
  $customer,
  $admin_user,
  $type,
  $local_name,
  $location,
  $subdomain = '',
  $forcessl  = false) {
  validate_re($type, 'static|php5|mono|redirect')
  validate_bool($forcessl)

  $domain = $subdomain ? {
    ''      => $basedomain,
    default => "${subdomain}.${basedomain}"
  }
  $base_dir = "/srv/${customer}"
  $admin_group = "${customer}_admins"
  $app_user = "${customer}_app"

  $location_as_filename = inline_template("<%= @location.gsub(/[^a-zA-Z0-9]/, '_') %>")
  $nginx_config_dir = "${base_dir}/etc/nginx/${domain}"
  $nginx_domain_config = "${base_dir}/etc/nginx/sites-enabled/${domain}.conf"

  if ($forcessl) {
    fail("forcessl: not yet implemented")
  }

  if (!defined(File[$nginx_config_dir])) {
    file { $nginx_config_dir:
      ensure => directory,
      mode   => 0770,
      owner  => $admin_user,
      group  => $admin_group;
    }
  }

  if (!defined(File[$nginx_domain_config])) {
    file { $nginx_domain_config:
      ensure  => present,
      content => template("hosting/nginx.app-site.conf.erb"),
      mode    => 0664,
      #      replace => false,
      owner   => $admin_user,
      group   => $admin_group;
    }
  }

  case $type {
    'mono'     : {
      # configure proxy pass through
      $nginx_config_content = template("hosting/nginx.mono-proxy.conf.erb")

      # configure fastcgi-mono-server4 instance
      if (!defined(Hosting::Customer_service["${customer}::${local_name}"])) {
        hosting::customer_service { "${customer}::${local_name}":
          base_dir        => $base_dir,
          app_user        => $app_user,
          admin_user      => $admin_user,
          admin_group     => $admin_group,
          service_name    => $local_name,
          service_content => template("hosting/mono-fcgi.service.erb"),
          enable          => true,
        }

        file { "${base_dir}/etc/mono-${local_name}":
          ensure => directory,
          mode   => 0770,
          owner  => $admin_user,
          group  => $admin_group;
        }
      }

      file { "${base_dir}/etc/mono-${local_name}/${domain}.${location_as_filename}.webapp":
        content => template('hosting/mono.webapp.erb'),
        mode    => 0660,
        owner   => $admin_user,
        group   => $admin_group;
      }
    }
    'php5'     : {
      # configure proxy pass through
      $nginx_config_content = template("hosting/nginx.php5-proxy.conf.erb")

      # configure php5-fcgi/fpm instance
      if (!defined(Hosting::Customer_service["${customer}::${local_name}"])) {
        hosting::customer_service { "${customer}::${local_name}":
          base_dir        => $base_dir,
          app_user        => $app_user,
          admin_user      => $admin_user,
          admin_group     => $admin_group,
          service_name    => $local_name,
          service_content => template("hosting/php5-fpm.service.erb"),
          enable          => true,
        }

        file {
          "${base_dir}/etc/php5-${local_name}":
            ensure => directory,
            mode   => 0750,
            owner  => $admin_user,
            group  => $admin_group;

          "${base_dir}/etc/php5-${local_name}/php-fpm.conf":
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
  file { "${nginx_config_dir}/${location_as_filename}.conf":
    content => $nginx_config_content,
    mode    => 0660,
    owner   => $admin_user,
    group   => $admin_group;
  # TODO: notify/restart nginx user instance
  }
}