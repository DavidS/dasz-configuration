node 'squeeze.dasz.at' {
  class { 'dasz::defaults':
    location         => tech21,
    force_nullmailer => true;
  }

  munin::plugin { 'zetbox_exceptions_ini50':
    source        => 'puppet:///modules/dasz/munin/zetbox_exceptions_',
    config_source => 'puppet:///modules/dasz/munin/zetbox_exceptions_ini50';
  }
}
