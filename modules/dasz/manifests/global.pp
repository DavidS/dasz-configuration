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
class dasz::global {
  package {
    [
      "vim"]:
      ensure => installed;

    [
      "vim-tiny", "nano"]:
      ensure => absent;
  }
}
