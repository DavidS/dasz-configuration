# This file is used for the initial puppet provisioning of the puppetmaster vbox
import "nodes/testnodes.pp"
include puppetmaster_example_org
