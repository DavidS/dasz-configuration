node 'jenkins.dasz.at' {
  class { 'dasz::defaults':
    location         => tech21,
    force_nullmailer => true;
  }

  apt::repository { 'jenkins':
    url        => 'http://pkg.jenkins-ci.org/debian',
    distro     => '',
    repository => 'binary/',
    key        => 'D50582E6',
    key_url    => 'http://pkg.jenkins-ci.org/debian/jenkins-ci.org.key';
  }
}
