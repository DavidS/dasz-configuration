# Class: dasz::global
#
# This module manages global dasz settings to be applied to every node.
#
# Parameters: none
#
# Actions:
#
# Requires: see Modulefile
#
# Sample Usage:
#
class dasz::global ($distro, $location) {
  package {
    [
      "vim",
      "lsb-release"]:
      ensure => installed;

    [
      "vim-tiny",
      "nano"]:
      ensure => absent;
  }

  apt::repository {
    "wheezy-base":
      url        => $location ? {
        'hetzner' => "http://mirror.hetzner.de/debian/packages",
        default   => 'http://http.debian.net/debian',
      },
      distro     => $distro,
      repository => "main",
      src_repo   => false,
      key        => "55BE302B";

    "wheezy-security":
      url        => "http://security.debian.org/",
      distro     => "${distro}/updates",
      repository => "main",
      src_repo   => false;

    "wheezy-puppetlabs":
      url        => "http://apt.puppetlabs.com",
      distro     => $distro,
      repository => "main",
      src_repo   => false,
      key        => "4BD6EC30",
      key_url    => "https://apt.puppetlabs.com/pubkey.gpg";
  }
}