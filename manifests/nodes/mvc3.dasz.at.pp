node 'mvc3.dasz.at' {
  class { 'dasz::defaults':
    location         => tech21,
    force_nullmailer => true;
  }
}