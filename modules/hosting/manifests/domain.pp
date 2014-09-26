define hosting::domain (
  $base_dir,
  $admin_user,
  $admin_group,
  $primary_ns_name   = $hosting::primary_ns_name,
  $secondary_ns_name = $hosting::secondary_ns_name,
  $primary_mx_name   = $hosting::primary_mx_name,
  $hosting_ipaddress = $hosting::hosting_ipaddress,
  $mail_ipaddress    = '',
  $hostmaster        = $hosting::hostmaster,
  $serial,
  $additional_rrs    = [],
  $has_mailinglists  = false) {
  include hosting

  $domain = $name
  $real_mail_ipaddress = $mail_ipaddress ? {
    ''        => $hosting_ipaddress,
    'hosting' => $hosting::hosting_ipaddress,
    default   => $mail_ipaddress,
  }

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

    "${base_dir}/mail/${domain}":
      ensure  => present,
      content => template("hosting/aliases.erb"),
      replace => false,
      mode    => 0644,
      owner   => $admin_user,
      group   => $admin_group;

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

    "/etc/bind/hosting_zones/${domain}.zone":
      content => template("hosting/bind.default-zone.erb"),
      mode    => 0640,
      owner   => root,
      group   => bind,
      before  => Concat["/etc/bind/named.conf.local"],
      notify  => Class['bind::service'];

    "/etc/exim4/virtual_domains_to_customer/${domain}":
      content => "*: ${base_dir}/mail\n",
      owner   => root,
      group   => root;
  }

  customer_logrotate {
    "${domain}_access":
      base_dir   => $base_dir,
      admin_user => $admin_user,
      service    => 'nginx',
      log_file   => 'access.log';

    "${domain}_error":
      base_dir   => $base_dir,
      admin_user => $admin_user,
      service    => 'nginx',
      log_file   => 'error.log';
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

  # manually configure nagios for check_dig and check_http
  @@file { "/etc/nagios3/conf.d/check_${domain}.cfg":
    ensure  => present,
    mode    => 0644,
    owner   => root,
    group   => root,
    content => template("hosting/nagios-check-domain.cfg.erb"),
    tag     => "nagios_host_",
    require => Package['nagios3'],
    notify  => Service['nagios3'];
  }

  dasz::nagios_zone_auth { $domain: ns => [$primary_ns_name, $secondary_ns_name]; }

  # avoid overlap with nginx_user_snip
  if (!defined(File["${base_dir}/etc/nginx/${domain}"])) {
    file { "${base_dir}/etc/nginx/${domain}":
      ensure => directory,
      mode   => 02770,
      owner  => $admin_user,
      group  => $admin_group;
    }
  }

  # bind zone config
  concat::fragment { $domain:
    target  => "/etc/bind/named.conf.local",
    content => "\nzone \"${domain}\" { type master; file \"/etc/bind/hosting_zones/${domain}.zone\"; };\n",
    order   => 50,
  }

  @@concat::fragment { "hosting::domain::slave::${domain}":
    target  => "/etc/bind/named.conf.local",
    content => "\nzone \"${domain}\" { type slave; masters { ${::ipaddress}; }; };\n",
    order   => 50,
    tag     => "hosting::domain::slave",
  }

  if $has_mailinglists {
    file { "/etc/exim4/mailman_domains/${name}":
      ensure  => present,
      content => '',
      mode    => 0644,
      owner   => root,
      group   => root;
    }
  }
}
