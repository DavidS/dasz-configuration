class site::internal_hosts {
  host {
    'db-server':
      ip => '10.0.0.1';

    'srv2008':
      host_aliases => ['srv2008.lan.dasz.at', 'srv2008.dasz'],
      ip           => '10.0.0.203';

    # required for nginx on hetz3
    'office':
      ip => '10.0.0.221';

    'jenkins':
      host_aliases => ['jenkins.dasz'],
      ip           => '10.0.0.216';

    'monitor':
      host_aliases => ['monitor.dasz'],
      ip           => '10.0.0.217';

    'kvmhost':
      host_aliases => ['kvmhost.dasz'],
      ip           => '10.0.0.191';
  }
}
