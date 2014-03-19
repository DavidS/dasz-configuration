define hosting::external_vhost ($base_dir, $admin_user, $admin_group) {
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

    "/etc/exim4/virtual_domains_to_customer/${domain}":
      content => "*: ${base_dir}/mail\n",
      owner   => root,
      group   => root;
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

  # TODO: manually configure nagios for check_dig
  #  @@file { "/etc/nagios3/conf.d/check_dns_${domain}.cfg":
  #    ensure  => present,
  #    mode    => 0644,
  #    owner   => root,
  #    group   => root,
  #    content => template("hosting/nagios-check-domain.cfg.erb"),
  #    tag     => "nagios_host_",
  #    require => Package['nagios3'],
  #    notify  => Service['nagios3'];
  #  }

  # avoid overlap with nginx_user_snip
  if (!defined(File["${base_dir}/etc/nginx/${domain}"])) {
    file { "${base_dir}/etc/nginx/${domain}":
      ensure => directory,
      mode   => 02770,
      owner  => $admin_user,
      group  => $admin_group;
    }
  }
}
