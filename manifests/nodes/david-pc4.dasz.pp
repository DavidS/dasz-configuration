node 'david-pc4.dasz' {
  class { 'dasz::defaults':
    location          => tech21,
    apt_dater_manager => true;
  }
}
