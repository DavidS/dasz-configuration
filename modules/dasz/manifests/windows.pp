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
}