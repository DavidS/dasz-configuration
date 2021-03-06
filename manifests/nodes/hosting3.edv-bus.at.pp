node 'hosting3.edv-bus.at' {
  $customers = loadyaml('/srv/puppet/secrets/hosting/customers.yaml')

  class {
    'dasz::defaults':
      location     => hetzner,
      munin_server => '88.198.141.234',
      admin_users  => false;

    'dasz::snips::systemd':
    ;

    'hosting':
      primary_fqdn          => 'hosting.edv-bus.at',
      primary_ns_name       => 'ns1.edv-bus.at',
      secondary_ns_name     => 'ns2.edv-bus.at',
      primary_mx_name       => $::fqdn,
      hosting_ipaddress     => $::ipaddress,
      hostmaster            => 'hostmaster.edv-bus.at',
      roundcube_db_password => file("/srv/puppet/secrets/${::fqdn}/roundcube_db.password"),
      webmail_vhost         => 'hosting.edv-bus.at',
      mailman_vhost         => 'hosting.edv-bus.at',
      sa_trusted_networks   => [$::ipaddress, '91.217.119.254'],
      junk_submitters       => $customers['junk_submitters'];

    'dasz::snips::adminmailer':
      recipient => 'root@dasz.at';
  }

  create_resources('hosting::customer', $customers['customers'], {
    dkim_public_key_data => file("/srv/puppet/secrets/${::fqdn}/dkim/dkim.public.key"),
  })

  # extra packages needed for customers
  # the first is even contrib
  package { [
    'postgresql-contrib',
    'nano']:
    ensure => installed;
  }

  # deploy a few custom web configurations for htpasswd
  file {
    '/etc/nginx/diakon.at/50-internes.conf':
      ensure => present,
      source => 'puppet:///modules/site/hosting/diakon.nginx.conf',
      mode   => '0644',
      owner  => root,
      group  => root,
      notify => Service['nginx'];
    '/etc/nginx/privat.black.co.at/50-htpasswd.conf':
      ensure => present,
      source => 'puppet:///modules/site/hosting/wdg-ba.nginx.conf',
      mode   => '0644',
      owner  => root,
      group  => root,
      notify => Service['nginx'];
    ['/etc/nginx/diakon.at.htpasswd', '/etc/nginx/wdg-ba.at.htpasswd']:
      mode  => '0600',
      owner => 'www-data',
      group => root;
  }

}
