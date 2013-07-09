# configures the munin plugin for the specified url
class dasz::snips::jenkins($url) {
  munin::plugin { 'jenkins_status':
    ensure         => 'present',
    source         => 'puppet:///modules/dasz/munin/jenkins_status',
    config_content => "[jenkins_*]\nenv.url $url\n";
  }
}

