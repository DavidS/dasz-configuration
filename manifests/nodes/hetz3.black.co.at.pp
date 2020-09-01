node 'hetz3.black.co.at' {
  class {
    'dasz::snips::systemd': ;
    'hosting::secondary_ns': ;
    'site::internal_hosts':
      notify => Service['nginx'];
  }

  nginx::vhost {
    'default':
      docroot        => 'none',
      create_docroot => false,
      template       => "site/${::fqdn}/nginx-default.site.erb";

    'office.dasz.at':
      docroot        => 'none',
      create_docroot => false,
      template       => "site/${::fqdn}/nginx-office.dasz.at.site.erb";

    'monitor.black.co.at':
      docroot        => 'none',
      create_docroot => false,
      template       => "site/${::fqdn}/nginx-monitor.black.co.at.site.erb";

    'oc.black.co.at':
      docroot        => 'none',
      create_docroot => false,
      template       => "site/${::fqdn}/nginx-oc.black.co.at.site.erb";

    'test.cheesy.at':
      docroot        => 'none',
      create_docroot => false,
      template       => "site/${::fqdn}/nginx-www.cheesy.at.site.erb";
  }

  file {
    '/etc/nginx/sites-available/default':
      ensure => absent;

    '/etc/nginx/sites-enabled/default':
      ensure => absent;

    '/etc/nginx/certs':
      ensure => directory,
      mode   => 0750,
      owner  => root,
      group  => 'www-data',
      notify => Service['nginx'];

    '/etc/nginx/certs/monitor.black.co.at.key':
      ensure => present,
      source => 'puppet:///secrets/ssl/monitor.black.co.at-privkey.pem',
      mode   => 0440,
      owner  => root,
      group  => 'www-data',
      notify => Service['nginx'];

    '/etc/nginx/certs/monitor.black.co.at.bundle.crt':
      ensure => present,
      source => 'puppet:///secrets/ssl/monitor.black.co.at-fullchain.pem',
      mode   => 0440,
      owner  => root,
      group  => 'www-data',
      notify => Service['nginx'];

    '/etc/nginx/certs/office.dasz.at.key':
      ensure => present,
      source => 'puppet:///secrets/ssl/office.dasz.at.key',
      mode   => 0440,
      owner  => root,
      group  => 'www-data',
      notify => Service['nginx'];

    '/etc/nginx/certs/office.dasz.at.bundle.crt':
      ensure => present,
      source => 'puppet:///secrets/ssl/office.dasz.at.bundle.crt',
      mode   => 0440,
      owner  => root,
      group  => 'www-data',
      notify => Service['nginx'];

    '/etc/nginx/certs/oc.black.co.at.key':
      ensure => present,
      source => 'puppet:///secrets/ssl/oc.black.co.at/privkey.pem',
      mode   => 0440,
      owner  => root,
      group  => 'www-data',
      notify => Service['nginx'];

    '/etc/nginx/certs/oc.black.co.at.bundle.crt':
      ensure => present,
      source => 'puppet:///secrets/ssl/oc.black.co.at/fullchain.pem',
      mode   => 0440,
      owner  => root,
      group  => 'www-data',
      notify => Service['nginx'];

    '/etc/nginx/certs/www.cheesy.at.key':
      ensure => present,
      source => 'puppet:///secrets/ssl/www.cheesy.at/privkey.pem',
      mode   => 0440,
      owner  => root,
      group  => 'www-data',
      notify => Service['nginx'];

    '/etc/nginx/certs/www.cheesy.at.bundle.crt':
      ensure => present,
      source => 'puppet:///secrets/ssl/www.cheesy.at/fullchain.pem',
      mode   => 0440,
      owner  => root,
      group  => 'www-data',
      notify => Service['nginx'];

    '/srv/dasz':
      ensure => directory,
      mode   => 0750,
      owner  => david,
      group  => www-data,
      before => Service['nginx'];

    # used to host the acme-challenge nonces
    "/var/lib/hosting/acme":
      ensure => directory,
      mode   => 0750,
      owner  => root,
      group  => 'www-data';
  }
}
