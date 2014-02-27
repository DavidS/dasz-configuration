class dasz::snips::adminmailer ($recipient) {
  file {
    "/etc/exim4/conf.d/router/110_dasz_adminmailer":
      content => template('dasz/exim4.110_dasz_adminmailer.erb'),
      mode    => 0644,
      owner   => root,
      group   => root,
      notify  => Service['exim4'];

    "/etc/exim4/adminmailer_domains":
      ensure  => directory,
      mode    => 0755,
      owner   => root,
      group   => root,
      purge   => true,
      recurse => true,
      force   => true;
  }

  File <<| tag == 'dasz_snips_adminmailer' |>>
}
