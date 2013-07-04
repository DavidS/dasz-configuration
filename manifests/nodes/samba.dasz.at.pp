node 'samba.dasz.at' {
  class { 'dasz::defaults':
    location         => hetzner,
    force_nullmailer => true;
  }
}