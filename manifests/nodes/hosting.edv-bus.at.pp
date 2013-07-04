node 'hosting.edv-bus.at' {
  class { 'dasz::defaults':
    location    => hetzner,
    admin_users => false; # collides with existing users
  }

  File <<| tag == 'nullmailer_workaround' |>>
}