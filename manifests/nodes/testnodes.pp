
# testagent in vagrant
# this can be used to test various stuff deployed via the puppetmaster
node 'testagent.example.org' {
  $testkey = 'OS/Yq8CnQ+XnsvwS783zCwHtTOtCuzPZhjM/sBZdTHTutLxxv/ahpPBOPPTrBWwSDeNL5BuW+IEcZF42c3V9WA=='

  class {
    'dasz::defaults':
      puppet_agent => false;

    "puppet":
      mode    => 'client',
      server  => 'puppetmaster.example.org',
      runmode => 'cron',
      require => Class['dasz::defaults'];

    "dhcpd":
      template => 'site/testagent/dhcpd.conf.erb';

    "foreman":
      install_mode         => 'none',
      install_proxy        => true,
      repo_flavour         => 'rc',
      proxy_feature_tftp   => true,
      proxy_feature_dhcp   => true,
      proxy_dhcp_omapi_key => $testkey;
  }
}

# my dev machine
# only used for stuff that has to run on bare metal
node 'david-lx1.dasz' {
  class { 'dasz::defaults':
    location     => hetzner,
    puppet_agent => false
  }
}