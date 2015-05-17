class site::internal_hosts {
  host {
    # required for nginx on hetz3
    'office':
      ip => '10.0.0.221';

    'monitor':
      host_aliases => ['monitor.dasz'],
      ip           => '10.0.0.217';

    'fw-maria.mariatreu.at':
      host_aliases => ['fw-maria'],
      ip           => '192.168.0.131';

    'fw-schmidg2.edv-bus.at':
      host_aliases => ['fw-schmidg', 'fw-schmidg2'],
      ip           => '192.168.0.9';
  }
}
