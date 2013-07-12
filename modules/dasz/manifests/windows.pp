# a windows machine
class dasz::windows($nagios_notifications, $nagios_allowed_hosts = '10.0.0.217') {
  # workaround https://github.com/chocolatey/chocolatey/issues/283
  registry::value { 'ChocolateyInstall':
    key  => 'HKLM\SYSTEM\CurrentControlSet\Control\Session Manager\Environment',
    data => 'C:\Chocolatey';
  }

  # global
  package { ['chocolatey', 'notepadplusplus', '7zip', 'adobereader', 'windirstat', 'javaruntime', 'Firefox', "NSClientPlusPlus.${::architecture}", 'sumatrapdf.install']:
    ensure   => installed,
    provider => 'chocolatey';
  }

  include munin::params

  # manually installed munin-node
  @@file { "${munin::params::include_dir}/${::fqdn}.conf":
    ensure  => present,
    path    => "${munin::params::include_dir}/${::fqdn}.conf",
    mode    => $munin::params::config_file_mode,
    owner   => $munin::params::config_file_owner,
    group   => $munin::params::config_file_group,
    content => template("dasz/munin-windows-host.conf.erb"),
    tag     => "munin_host_",
  }

  # manually configure nagios for checking via nsclient++
  @@file { "/etc/nagios3/conf.d/${::fqdn}.cfg":
    ensure  => present,
    mode    => 0644,
    owner   => root,
    group   => root,
    content => template("dasz/nagios-windows-host.cfg.erb"),
    tag     => "nagios_host_",
    notify  => Service['nagios3'];
  }

  file {
    'C:\Program Files\NSClient++\boot.ini':
      ensure  => present,
      source  => "puppet:///modules/dasz/nagios/nsclient-boot.ini",
      require => Package["NSClientPlusPlus.${::architecture}"],
      notify  => Service["nscp"];
    'C:\Program Files\NSClient++\nsclient.ini':
      ensure  => present,
      content => template("dasz/nsclient.ini.erb"),
      require => Package["NSClientPlusPlus.${::architecture}"],
      notify  => Service["nscp"];
  }

  service { "nscp":
    ensure  => running,
    enable  => true,
    require => Package["NSClientPlusPlus.${::architecture}"],
  }
}
