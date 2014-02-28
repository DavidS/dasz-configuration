node 'jenkins.dasz.at' {
  class {
    'dasz::defaults':
      location         => tech21,
      force_nullmailer => true;

    'dasz::snips::jenkins':
      url => 'http://jenkins:8080';

  }

  dasz::zetbox::monitor {
    'zetbox-nh':
      url => "http://jenkins:7007/zetbox/develop/PerfMon.facade";

    #    'zetbox_zetbox-ef':
    #      url => "http://build01-win7/jenkins/zetbox-develop/PerfMon.facade";

    'ini50':
      url       => "http://db-server/PerfMon.facade",
      fake_host => 'db-server-monitor';
  }

  dasz::zetbox::monitor_exceptions { 'ini50':
    user      => 'root',
    pguser    => 'ini50',
    pgcluster => '8.4/db-server:5444',
    fake_host => 'db-server-monitor';
  }

  dasz::zetbox::monitor_fake_host { 'db-server-monitor': folder => 'Initiative50'; }

  package { 'postgresql-client-8.4': ensure => present; }
}
