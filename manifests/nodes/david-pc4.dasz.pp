node 'david-pc4.dasz' {
  class {
    'dasz::defaults':
      location          => at,
      apt_dater_manager => true,
      force_nullmailer  => true;

    'dasz::snips::systemd':
    ;

    'dasz::snips::mono_backport':
    ;
  }
}
