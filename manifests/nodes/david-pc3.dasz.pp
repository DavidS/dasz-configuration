# windows pc
node 'david-pc3.dasz' {
  include dasz::windows::devtop

  # david only
  package { ['virtuawin']:
    ensure   => installed,
    provider => 'chocolatey';
  }
}
