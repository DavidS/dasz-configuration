# a devop's desktop (if it has to run windows)
class dasz::windows::devtop {
  class { 'dasz::windows': nagios_notifications => false; }

  # global
  package { ['TortoiseGit', 'snoop', 'putty', 'filezilla',]:
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
}