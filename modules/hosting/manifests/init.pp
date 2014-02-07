# Class: hosting
#
# This module manages hosting
#
# Parameters: none
#
# Actions:
#
# Requires: see Modulefile
#
# Sample Usage:
#
class hosting (
  $primary_fqdn   = $::fqdn,
  $primary_ns_name,
  $secondary_ns_name,
  $primary_mx_name,
  $hosting_ipaddress,
  $hostmaster,
  $cert_base_path = 'puppet:///secrets',
  $roundcube_db_password,
  $webmail_vhost) {
  include dasz::defaults, bind, postgresql, mysql

  if (!defined(Package['git'])) {
    package { git: ensure => installed }
  }

  class {
    'nginx':
      template => 'hosting/nginx.frontend.conf.erb';

    'dovecot':
    ;

    'exiscan':
      sa_bayes_sql_local    => true,
      sa_bayes_sql_dsn      => "DBI:Pg:dbname=spamassassin",
      sa_bayes_sql_username => 'debian-spamd',
      exim_source_dir       => "puppet:///modules/hosting/exim",
      other_hostnames       => [$::fqdn, "+virtual_domains"],
      relay_domains         => ["@mx_any/ignore=+localhosts", "+virtual_domains"],
      local_delivery        => 'dovecot_delivery',
      greylist_local        => true,
      greylist_dsn          => 'servers=(/var/run/postgresql/.s.PGSQL.5432)/greylist/Debian-exim',
      greylist_sql_username => 'Debian-exim';

    '::roundcube':
      db_password => $roundcube_db_password;
  }

  # installing roundcube before php5-fpm pulls in apache
  Package["php5-fpm"] -> Class["::roundcube"]
  Class["nginx"] -> Class["::roundcube"]

  package { ["dovecot-managesieved", "dovecot-sieve"]:
    ensure => installed,
    notify => Service['dovecot'];
  }

  file { "${dovecot::config_dir}/local.conf":
    source  => "puppet:///modules/hosting/dovecot.local.conf",
    mode    => 0644,
    owner   => $dovecot::config_file_owner,
    group   => $dovecot::config_file_group,
    require => Package[$dovecot::package],
    notify  => Service['dovecot'];
  }

  hosting::ssl_cert {
    "dovecot::${primary_fqdn}":
      ca          => thawte,
      cert_file   => "${dovecot::config_dir}/dovecot.pem",
      cert_source => "${cert_base_path}/ssl/${primary_fqdn}/cert.pem",
      key_file    => "${dovecot::config_dir}/private/dovecot.pem",
      key_source  => "${cert_base_path}/ssl/${primary_fqdn}/privkey.pem",
      cert_mode   => 0644,
      cert_owner  => $dovecot::config_file_owner,
      cert_group  => $dovecot::config_file_group,
      require     => Package[$dovecot::package],
      notify      => Service['dovecot'];

    "exim::${primary_fqdn}":
      ca          => thawte,
      cert_file   => "${exim::config_dir}/exim.crt",
      cert_source => "${cert_base_path}/ssl/${primary_fqdn}/cert.pem",
      key_file    => "${exim::config_dir}/exim.key",
      key_source  => "${cert_base_path}/ssl/${primary_fqdn}/privkey.pem",
      cert_mode   => 0644,
      cert_owner  => $exim::config_file_owner,
      cert_group  => $exim::config_file_group,
      key_mode    => 0640,
      key_group   => "Debian-exim",
      require     => Package[$exim::package],
      notify      => Service['exim'];
  }

  # use mono3
  apt::repository { "zetbox":
    url        => $dasz::defaults::location ? {
      'hetzner' => "http://office.dasz.at/debian",
      'tech21'  => "http://kvmhost.dasz/debian",
      'vagrant' => "http://kvmhost.dasz/debian",
      default   => "http://office.dasz.at/debian",
    },
    distro     => zetbox,
    repository => "main",
    trusted    => yes;
  }

  package {
    [
      "mono-complete",
      "mono-fastcgi-server",
      "php5-fpm",
      "php5-gd",
      "php5-mysql",
      "php5-pgsql",
      "php5-sqlite",
      "fetchmail",
      "imagemagick",
      ]:
      ensure => installed;

    "policykit-1":
      ensure => installed,
      notify => Exec['dbus-restart']
  }

  # import certificates from mozilla
  exec { "/usr/bin/mozroots --import --sync":
    refreshonly => true,
    subscribe   => Package['mono-complete'];
  }

  exec {
    'systemd-reload':
      command     => '/bin/systemctl --system daemon-reload',
      refreshonly => true,
      onlyif      => '/bin/systemctl > /dev/null',
      require     => Package['systemd'];

    'dbus-restart':
      command     => '/bin/systemctl restart dbus.service',
      refreshonly => true,
      onlyif      => '/bin/systemctl > /dev/null',
      require     => Package['systemd'];
  }

  file {
    "/etc/nginx/php5-fpm_params":
      source  => "puppet:///modules/hosting/nginx.php5-fpm_params",
      mode    => 0644,
      owner   => root,
      group   => root,
      require => Package['nginx'],
      notify  => Service['nginx'];

    "/etc/nginx/customer_proxy_params":
      source  => "puppet:///modules/hosting/nginx.customer_proxy_params",
      mode    => 0644,
      owner   => root,
      group   => root,
      require => Package['nginx'],
      notify  => Service['nginx'];

    "/var/lib/hosting":
      ensure => directory,
      mode   => 0755,
      owner  => root,
      group  => root;

    "/etc/bind/hosting_zones":
      ensure  => directory,
      mode    => 0750,
      owner   => root,
      group   => bind,
      require => Class['bind::installation'];

    "/etc/ssl/www":
      ensure => directory,
      mode   => 0710,
      owner  => root,
      group  => www-data;
  }

  concat { "/etc/bind/named.conf.local":
    mode    => 644,
    owner   => root,
    group   => root,
    require => Class['bind::installation'],
    notify  => Class['bind::service'];
  }

  vcsrepo { "/var/lib/hosting/dasz-configuration":
    ensure   => present,
    revision => 'origin/master',
    provider => git,
    source   => "https://github.com/DavidS/dasz-configuration.git",
    owner    => root,
    group    => root,
    require  => Package['git'];
  }

  # # exim configuration
  file { "/etc/exim4/virtual_domains_to_customer":
    ensure => directory,
    mode   => 0640,
    owner  => root,
    group  => 'Debian-exim';
  }

  class {
    "hosting::roundcube":
      vhost => $webmail_vhost;

    "hosting::phpmyadmin":
      vhost => $webmail_vhost
  }

}

# webmail configuration
class hosting::roundcube ($vhost, $url_path = '/webmail', $fpm_socket = '/var/run/php5-fpm.sock', $root = '/var/lib/roundcube',) {
  file { "/etc/nginx/${vhost}/50-webmail.conf":
    content => template("roundcube/nginx.php5-proxy.conf.erb"),
    mode    => 0644,
    owner   => root,
    group   => root,
    require => Package['nginx'],
    notify  => Service['nginx'];
  }
}

# phpmyadmin configuration
class hosting::phpmyadmin ($vhost, $url_path = '/phpmyadmin', $fpm_socket = '/var/run/php5-fpm.sock',) {
  package { "phpmyadmin": ensure => installed; }

  file { "/etc/nginx/${vhost}/50-phpmyadmin.conf":
    ensure  => present,
    content => template("hosting/nginx.php5-phpmyadmin-proxy.conf.erb"),
    mode    => 0644,
    owner   => root,
    group   => root,
    require => [Package['nginx'], Package["phpmyadmin"]],
    notify  => Service['nginx'];
  }
}
