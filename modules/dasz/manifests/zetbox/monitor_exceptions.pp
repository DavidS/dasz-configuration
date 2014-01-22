# monitors zetbox exceptions in the database
# may fake the hostname for better overview in munin
# fake hosts have to be configured manually
define dasz::zetbox::monitor_exceptions ($user, $pguser, $pgcluster, $fake_host = '') {
  $host_config = $fake_host ? {
    ''      => '',
    default => "env.FAKE_HOST ${fake_host}\n",
  }

  munin::plugin {
    "zetbox_exceptions_${name}":
      source         => 'puppet:///modules/dasz/zetbox/munin.zetbox_exceptions_',
      config_content => "[zetbox_exceptions_${name}]\nuser ${user}\nenv.PGUSER ${pguser}\nenv.PGCLUSTER ${pgcluster}\n${host_config}\n";
  }
}
