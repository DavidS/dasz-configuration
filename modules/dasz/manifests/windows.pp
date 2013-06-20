# a windows machine
class dasz::windows {
  # workaround https://github.com/chocolatey/chocolatey/issues/283
  registry::value { 'ChocolateyInstall':
    key  => 'HKLM\SYSTEM\CurrentControlSet\Control\Session Manager\Environment',
    data => 'C:\Chocolatey';
  }

  # global
  package { ['chocolatey', 'notepadplusplus', '7zip', 'adobereader', 'windirstat', 'javaruntime', 'Firefox',]:
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
}