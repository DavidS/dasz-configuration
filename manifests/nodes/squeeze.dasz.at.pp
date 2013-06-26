node 'squeeze.dasz.at' {
  class { 'dasz::defaults': location => tech21; }
  munin::plugin { 'zetbox_exceptions_ini50':
    source => 'dasz/munin/zetbox_exceptions_',
    source_config => 'dasz/munin/zetbox_exceptions_ini50',
    linkplugins => true;
  }
}
