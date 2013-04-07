node default {
  # Hope springs eternal
  $distro = $lsbdistcodename

  class {
    "apt":
      force_sources_list_d => true;

    "dasz::global":
      distro   => $distro,
      location => "unknown",;

    "ntp":
    ;

    "openssh": # TODO: add host key management
    ;

    "puppet":
      mode    => 'client',
      server  => 'puppetmaster.dasz.at', # can be configured more globally
      runmode => 'cron',
      require => Class['dasz::global'];

    "rsyslog":
    ;

    "sudo":
    ;
  }
}