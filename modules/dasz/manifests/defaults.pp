class dasz::defaults {
  # Hope springs eternal
  $distro = $lsbdistcodename

  class {
    "apt":
      force_sources_list_d => true;

    "dasz::global":
      distro   => $distro,
      location => "unknown";

    "ntp":
    ;

    "openssh": # TODO: add host key management
    ;

    "rsyslog":
    ;

    "sudo":
    ;
  }
}