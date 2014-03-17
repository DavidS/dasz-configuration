# configures the munin plugin for the specified url
class dasz::snips::jenkins ($url) {
  package {
    'jenkins':
      # only upgrade when required
      ensure => held;

    [
      'libwww-perl',
      'build-essential',
      'devscripts']:
      ensure => present;
  }

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

  file { "/var/lib/jenkins/rules":
    ensure  => directory,
    source  => "puppet:///modules/dasz/jenkins/rules",
    mode    => 0755,
    owner   => jenkins,
    group   => adm,
    recurse => true,
    purge   => true,
    force   => true;
  }
}

