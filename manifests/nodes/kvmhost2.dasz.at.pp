node 'kvmhost2.dasz.at' {
  class { 'dasz::defaults':
    location    => tech21,
    ssh_address => '10.0.0.192';
  }
}
