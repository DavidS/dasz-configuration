node 'david-lx1.dasz' {
  class { 'dasz::defaults':
    location          => at,
    apt_dater_manager => true,
    munin_smart_disks => ['sda', 'sdb'],
    force_nullmailer  => true;
  }

  apt::repository {
    "zetbox":
      url        => "http://kvmhost.dasz/debian",
      distro     => zetbox,
      repository => "main";

    "sid-sources":
      url        => "http://kvmhost.dasz:3142/debian",
      distro     => sid,
      repository => "main",
      src_repo   => true;
  }
}
