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
  $primary_fqdn        = $::fqdn,
  $primary_ns_name     = $::fqdn,
  $secondary_ns_name   = $::fqdn,
  $primary_mx_name     = $::fqdn,
  $hosting_ipaddress   = $::ipaddress,
  $hostmaster,
  $ca                  = 'thawte2014',
  $cert_base_path      = 'puppet:///secrets',
  $roundcube_db_password,
  $webmail_vhost       = $::fqdn,
  $mailman_vhost       = $::fqdn,
  $sa_trusted_networks = $::ipaddress,
  $junk_submitters     = []) {
  include dasz::defaults, dasz::snips::systemd, bind, postgresql, mysql

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
      sa_trusted_networks   => $sa_trusted_networks,
      exim_source_dir       => "puppet:///modules/hosting/exim",
      other_hostnames       => [$::fqdn, "+virtual_domains"],
      relay_domains         => ["@mx_any/ignore=+localhosts", "+virtual_domains"],
      local_delivery        => 'dovecot_delivery',
      greylist_local        => true,
      greylist_dsn          => 'servers=(/var/run/postgresql/.s.PGSQL.5432)/greylist/Debian-exim',
      greylist_sql_username => 'Debian-exim',
      junk_submitters       => $junk_submitters,
      dkim_private_key      => 'puppet:///secrets/dkim/dkim.private.key',
  }

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
      ca          => $ca,
      cert_file   => "${dovecot::config_dir}/dovecot.pem",
      cert_source => "${cert_base_path}/ssl/${primary_fqdn}/${primary_fqdn}.crt",
      key_file    => "${dovecot::config_dir}/private/dovecot.pem",
      key_source  => "${cert_base_path}/ssl/${primary_fqdn}/${primary_fqdn}.key",
      cert_mode   => 0644,
      cert_owner  => $dovecot::config_file_owner,
      cert_group  => $dovecot::config_file_group,
      require     => Package[$dovecot::package],
      notify      => Service['dovecot'];

    "exim::${primary_fqdn}":
      ca          => $ca,
      cert_file   => "${exim::config_dir}/exim.crt",
      cert_source => "${cert_base_path}/ssl/${primary_fqdn}/${primary_fqdn}.crt",
      key_file    => "${exim::config_dir}/exim.key",
      key_source  => "${cert_base_path}/ssl/${primary_fqdn}/${primary_fqdn}.key",
      cert_mode   => 0644,
      cert_owner  => $exim::config_file_owner,
      cert_group  => $exim::config_file_group,
      key_mode    => 0640,
      key_group   => "Debian-exim",
      require     => Package[$exim::package],
      notify      => Service['exim'];
  }

  package {
    [
      "php5-curl",
      "php5-fpm",
      "php5-gd",
      "php5-imap",
      "php5-mysql",
      "php5-pgsql",
      "php5-sqlite",
      "php5-xmlrpc",
      "fetchmail",
      "imagemagick",
      ]:
      ensure => installed;

    "policykit-1":
      ensure => installed,
      notify => Exec['dbus-restart']
  }

  file {
    "/etc/nginx/php5-fpm_params":
      source  => "puppet:///modules/hosting/nginx.php5-fpm_params",
      mode    => 0644,
      owner   => root,
      group   => root,
      require => Package['nginx'],
      notify  => Service['nginx'];

    "/etc/nginx/customer_php5-fpm_params":
      source  => "puppet:///modules/hosting/nginx.customer_php5-fpm_params",
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

    "/etc/nginx/customer_fastcgi_params":
      source  => "puppet:///modules/hosting/nginx.customer_fastcgi_params",
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

    "/usr/local/bin/update-apps-core":
      source => "puppet:///modules/hosting/update-apps-core",
      mode   => 0755,
      owner  => root,
      group  => root;
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
  file {
    "/etc/exim4/virtual_domains_to_customer":
      ensure  => directory,
      mode    => 0750,
      owner   => root,
      group   => 'Debian-exim',
      require => Class['exim'];

    "/etc/exim4/conf.d/main/01_hosting_primary_hostname":
      content => "MAIN_HARDCODE_PRIMARY_HOSTNAME = ${primary_fqdn}\n",
      mode    => 0644,
      owner   => root,
      group   => root,
      notify  => Service['exim'];

    "/etc/exim4/mailman_domains":
      ensure  => directory,
      mode    => 0750,
      owner   => root,
      group   => 'Debian-exim',
      purge   => true,
      recurse => true,
      force   => true,
      require => Class['exim'];
  }

  # install nginx and php5-fpm before any of the applications pulls in a wrong php with apache
  Package['nginx', "php5-fpm"] ->
  class {
    '::roundcube':
      db_password => $roundcube_db_password,
      mail_domain => $primary_fqdn;

    "hosting::roundcube":
      vhost => $webmail_vhost;

    "hosting::phpmyadmin":
      vhost => $webmail_vhost;

    "hosting::mailman":
      vhost => $mailman_vhost;
  }

  # allow global access via localhost with password for phppgadmin
  postgresql::hba {
    "hba_localhost_admin":
      ensure   => 'present',
      type     => 'host',
      database => 'postgres',
      user     => 'all',
      address  => '127.0.0.1/32',
      method   => 'md5';

    "hba_localhost6_admin":
      ensure   => 'present',
      type     => 'host',
      database => 'postgres',
      user     => 'all',
      address  => '::1/128',
      method   => 'md5';
  }

  # manually configure nagios check_httpname_follow command
  @@file { "/etc/nagios3/conf.d/check_domain_commands.cfg":
    ensure  => present,
    mode    => 0644,
    owner   => root,
    group   => root,
    content => template("hosting/nagios-check-domain-commands.cfg.erb"),
    tag     => "nagios_host_",
    require => Package['nagios3'],
    notify  => Service['nagios3'];
  }
}

# webmail configuration
class hosting::roundcube ($vhost, $url_path = '/webmail', $fpm_socket = '/var/run/php5-fpm.sock', $root = '/var/lib/roundcube',) {
  file { "/etc/nginx/${vhost}/50-webmail.conf":
    content => template("roundcube/nginx.php5-proxy.conf.erb"),
    mode    => 0644,
    owner   => root,
    group   => root,
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
    notify  => Service['nginx'];
  }

}

class hosting::mailman (
  $vhost,
  $url_path    = '/cgi-bin/mailman',
  $fcgi_socket = '/var/run/fcgiwrap.socket',
  $root        = '/usr/lib/cgi-bin/mailman',) {
  file { "/etc/nginx/${vhost}/50-mailman.conf":
    content => template("hosting/nginx.fcgi-mailman-proxy.conf.erb"),
    mode    => 0644,
    owner   => root,
    group   => root,
    notify  => Service['nginx'];
  }

  # mailman
  package { "mailman": ensure => installed }

}
