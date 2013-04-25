# windows pc
node 'david-pc3.dasz' {
  # workaround https://github.com/chocolatey/chocolatey/issues/283
  registry::value { 'ChocolateyInstall':
    key  => 'HKLM\SYSTEM\CurrentControlSet\Control\Session Manager\Environment',
    data => 'C:\Chocolatey';
  }

  # global
  package { [
    'chocolatey',
    'notepadplusplus',
    'TortoiseGit',
    'snoop',
    'putty',
    '7zip',
    'filezilla',
    'adobereader',
    'windirstat',
    'javaruntime',
    'Firefox']:
    ensure   => installed,
    provider => 'chocolatey';
  }

  # david only
  package { ['virtuawin']:
    ensure   => installed,
    provider => 'chocolatey';
  }

  # actually, I'm still on 8.4.8 for compatability, but that is not available
  # package { 'postgresql':
  #   ensure   => '8.4.14',
  #   provider => 'chocolatey';
  #}

  # other stuff available, but outdated: gimp (2.8.2 < 2.8.4), thunderbird (16 < 17), monodevelop (2.x < 4),
  # sumatrapdf.install (2.2 < 2.2.1), virtualbox (4.2.10 < 4.2.12), puppet (2.7.17 < 3.1), sharpdevelop (4.2 < 4.3),
  # MicrosoftSecurityEssentials (2.0.657.0 < 4.2.223.0)

  # investigate: vagrant, nuget, SqlServerExpress, procmon, procexp, visual studio 2012, keepass, 7zip, skype, libreoffice,
  # posh-git, Monosnap, stylecop

  # missing:
}
