# tmp stub
node 'hosting3.edv-bus.at' {
  class { 'dasz::defaults':
    location    => hetzner,
    admin_users => false; # collides with existing users
  }
}
