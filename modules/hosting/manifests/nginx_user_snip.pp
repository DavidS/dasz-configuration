define hosting::nginx_user_snip ($domain, $customer, $admin_user, $type, $local_name, $location, $flags = '') {
  $base_dir = "/srv/${customer}"
  $admin_group = "${customer}_admins"
  $app_user = "${customer}_app"
  $location_as_filename = inline_template("<%= @location.replace('[^a-zA-Z0-9]', '_') %>")

  case $type {
    'static'   : {
      # simply configure an override with nginx
      file { "${base_dir}/etc/nginx/${domain}/${location_as_filename}.conf":
        content => template("hosting/nginx.user-static.conf.erb"),
        mode    => 0660,
        owner   => $admin_user,
        group   => $admin_group;
      # TODO: notify/restart nginx user instance
      }
    }
    'php5'     : {
      # configure php5-fcgi instance
      # configure proxy pass through
    }
    'mono'     : {
      # configure fastcgi-mono-server4 instance
      # configure proxy pass through
    }
    'redirect' : {
      # simply configure the redirect with nginx
      file { "${base_dir}/etc/nginx/${domain}/${location_as_filename}.conf":
        content => template("hosting/nginx.user-redirect.conf.erb"),
        mode    => 0660,
        owner   => $admin_user,
        group   => $admin_group;
      # TODO: notify/restart nginx user instance
      }
    }
  }
}