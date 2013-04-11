node agent {
  include dasz::defaults

  class { "puppet":
    mode    => 'client',
    server  => 'puppetmaster.dasz.at', # can be configured more globally
    runmode => 'cron',
    require => Class['dasz::global'];
  }
}