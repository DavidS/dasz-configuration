# configures the munin plugin for the specified url
class dasz::snips::jenkins ($url) {
  package { ['jenkins', 'libwww-perl',]: ensure => present; }

  munin::plugin { 'jenkins_status':
    ensure         => 'present',
    source         => 'puppet:///modules/dasz/munin/jenkins_status',
    config_content => "[jenkins_*]\nenv.url $url\n";
  }

  apt::repository { 'jenkins':
    url        => 'http://pkg.jenkins-ci.org/debian',
    distro     => '',
    repository => 'binary/',
    key        => 'D50582E6',
    key_url    => 'http://pkg.jenkins-ci.org/debian/jenkins-ci.org.key';
  }
}

