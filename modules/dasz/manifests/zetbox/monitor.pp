# monitors a zetbox instance via the PerfMon facade
# may fake the hostname for better overview in munin
# fake hosts have to be configured manually
define dasz::zetbox::monitor ($url, $fake_host = '') {
  $host_config = $fake_host ? {
    ''      => '',
    default => "env.FAKE_HOST ${fake_host}\n",
  }

  if (!defined(Package['libwww-perl'])) {
    package { "libwww-perl": ensure => installed }
  }

  munin::plugin {
    "zetbox_facade_calls_${name}":
      source         => 'puppet:///modules/dasz/zetbox/munin.zetbox_facade_calls_',
      config_content => "[zetbox_facade_calls_${name}]\nenv.PERFMON_URL ${url}\n${host_config}\n";

    "zetbox_facade_cls_calls_${name}":
      source         => 'puppet:///modules/dasz/zetbox/munin.zetbox_facade_cls_calls_',
      config_content => "[zetbox_facade_cls_calls_${name}]\nenv.PERFMON_URL ${url}\n${host_config}\n";

    "zetbox_facade_cls_duration_${name}":
      source         => 'puppet:///modules/dasz/zetbox/munin.zetbox_facade_cls_duration_',
      config_content => "[zetbox_facade_cls_duration_${name}]\nenv.PERFMON_URL ${url}\n${host_config}\n";

    "zetbox_facade_duration_${name}":
      source         => 'puppet:///modules/dasz/zetbox/munin.zetbox_facade_duration_',
      config_content => "[zetbox_facade_duration_${name}]\nenv.PERFMON_URL ${url}\n${host_config}\n";

    "zetbox_queries_cls_calls_${name}":
      source         => 'puppet:///modules/dasz/zetbox/munin.zetbox_queries_cls_calls_',
      config_content => "[zetbox_queries_cls_calls_${name}]\nenv.PERFMON_URL ${url}\n${host_config}\n";

    "zetbox_queries_cls_duration_${name}":
      source         => 'puppet:///modules/dasz/zetbox/munin.zetbox_queries_cls_duration_',
      config_content => "[zetbox_queries_cls_duration_${name}]\nenv.PERFMON_URL ${url}\n${host_config}\n";
  }
}
