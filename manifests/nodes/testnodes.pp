
# testagent in vagrant
# this can be used to test various stuff deployed via the puppetmaster
node 'testagent.example.org' inherits agent {
}

# my dev machine
# only used for stuff that has to run on bare metal
node 'david-lx1.dasz' {
  include 'dasz::defaults'
}