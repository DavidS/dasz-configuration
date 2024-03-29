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

    'www.edv-bus.at':
      docroot        => 'none',
      create_docroot => false,
      template       => "site/${::fqdn}/nginx-www.edv-bus.at.site.erb";

    'www.connyspatchwork.at':
      docroot        => 'none',
      create_docroot => false,
      template       => "site/${::fqdn}/nginx-www.connyspatchwork.at.site.erb";

    'oc.black.co.at':
      docroot        => 'none',
      create_docroot => false,
      template       => "site/${::fqdn}/nginx-oc.black.co.at.site.erb";

    'www.cheesy.at':
      docroot        => 'none',
      create_docroot => false,
      template       => "site/${::fqdn}/nginx-www.cheesy.at.site.erb";

    'plausible.black.co.at':
      docroot        => 'none',
      create_docroot => false,
      template       => "site/${::fqdn}/nginx-plausible.black.co.at.site.erb";

    'club.black.co.at':
      docroot        => 'none',
      create_docroot => false,
      template       => "site/${::fqdn}/nginx-club.black.co.at.site.erb";
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

    '/etc/nginx/certs/www.edv-bus.at.key':
      ensure => present,
      source => 'puppet:///secrets/ssl/www.edv-bus.at/privkey.pem',
      mode   => 0440,
      owner  => root,
      group  => 'www-data',
      notify => Service['nginx'];

    '/etc/nginx/certs/www.edv-bus.at.bundle.crt':
      ensure => present,
      source => 'puppet:///secrets/ssl/www.edv-bus.at/fullchain.pem',
      mode   => 0440,
      owner  => root,
      group  => 'www-data',
      notify => Service['nginx'];

    '/etc/nginx/certs/www.connyspatchwork.at.key':
      ensure => present,
      source => 'puppet:///secrets/ssl/www.connyspatchwork.at/privkey.pem',
      mode   => 0440,
      owner  => root,
      group  => 'www-data',
      notify => Service['nginx'];

    '/etc/nginx/certs/www.connyspatchwork.at.bundle.crt':
      ensure => present,
      source => 'puppet:///secrets/ssl/www.connyspatchwork.at/fullchain.pem',
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

    '/etc/nginx/certs/plausible.black.co.at.key':
      ensure => present,
      source => 'puppet:///secrets/ssl/plausible.black.co.at/privkey.pem',
      mode   => 0440,
      owner  => root,
      group  => 'www-data',
      notify => Service['nginx'];

    '/etc/nginx/certs/plausible.black.co.at.bundle.crt':
      ensure => present,
      source => 'puppet:///secrets/ssl/plausible.black.co.at/fullchain.pem',
      mode   => 0440,
      owner  => root,
      group  => 'www-data',
      notify => Service['nginx'];

    '/etc/nginx/certs/club.black.co.at.key':
      ensure => present,
      source => 'puppet:///secrets/ssl/club.black.co.at/privkey.pem',
      mode   => 0440,
      owner  => root,
      group  => 'www-data',
      notify => Service['nginx'];

    '/etc/nginx/certs/club.black.co.at.bundle.crt':
      ensure => present,
      source => 'puppet:///secrets/ssl/club.black.co.at/fullchain.pem',
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
