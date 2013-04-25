# windows pc
node 'david-pc3.dasz' {
  class { "dasz::windows_devtop": }

  # david only
  package { ['virtuawin']:
    ensure   => installed,
    provider => 'chocolatey';
  }
}
