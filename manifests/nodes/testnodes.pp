
# testagent in vagrant
# this can be used to test various stuff deployed via the puppetmaster
node 'testagent.example.org' {
  class {
    'dasz::defaults':
      puppet_agent => false;

    "puppet":
      mode    => 'client',
      server  => 'puppetmaster.example.org',
      runmode => 'cron',
      require => Class['dasz::defaults'];
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