node 'david-lx1.dasz' {
  class { 'dasz::defaults':
    location          => tech21,
    apt_dater_manager => true,
    force_nullmailer  => true;
  }
}