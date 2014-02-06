define hosting::cert ($ca, $base_path, $cn_aliases = []) {
  $cert_file = "/etc/ssl/www/${name}.crt.pem"

  file {
    "/etc/nginx/sites-enabled/98-${name}-ssl.conf":
      content => template("hosting/nginx.frontend-sslsite.erb"),
      mode    => 0644,
      owner   => root,
      group   => root,
      require => Package['nginx'],
      notify  => Service['nginx'];

    "/etc/ssl/www/${name}.key.pem":
      source    => "${base_path}/ssl/${name}/privkey.pem",
      show_diff => false,
      mode      => 0640,
      owner     => root,
      group     => www-data;
  }

  if (!defined(File["/etc/nginx/${name}"])) {
    file { "/etc/nginx/${name}":
      ensure  => directory,
      mode    => 0755,
      owner   => root,
      group   => root,
      require => Package['nginx'],
      notify  => Service['nginx'];
    }
  }

  concat { $cert_file:
    mode   => 0640,
    owner  => root,
    group  => www-data,
    notify => Service["nginx"];
  }

  concat::fragment { "${name}.crt.pem#certificate":
    target => $cert_file,
    order  => 10,
    source => "${base_path}/ssl/${name}/cert.pem";
  }

  if ($ca != self) {
    concat::fragment { "${name}.crt.pem#bundle":
      target => $cert_file,
      order  => 90,
      source => "puppet:///modules/hosting/ssl/${ca}.bundle.pem";
    }
  }
}