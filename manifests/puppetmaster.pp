include "apt"

class {
#  "foreman":
#    url           => "http://${::fqdn}",
#    puppet_server => $::fqdn,
#    enc           => false, # TODO: enable this
#    reports       => true,
#    facts         => true,
#    storeconfigs  => false,
#    db            => postgresql,
#    db_user       => 'foreman',
#    db_password   => file("/srv/puppet/secrets/puppetmaster/foreman.password");
	"ntp" : ;

	"openssh" : # TODO: add host key management
;

	"postgresql" : ;

	"puppet" :
		template => 'site/puppetmaster/puppet.conf.erb',
		mode => 'server',
		server => 'puppetmaster.dasz.at', # can be configured more globally
		runmode => 'manual', # change this later (to cron), see also croninterval, croncommand
		db => 'puppetdb',
		db_server => $fqdn, # TODO: should be default?
		db_port => 8081, # TODO: should be default for puppetdb?
		dns_alt_names => '' ;

	"puppetdb" :
		db_type => 'postgresql',
		db_host => 'localhost',
		db_user => 'puppetdb',
		db_password => file("/srv/puppet/secrets/puppetmaster/puppetdb.password") ;

	"puppetdb::postgresql" : ;

	"rsyslog" : ;

	"sudo" : ;
}
apt::repository {
	"wheezy" :
		url => "http://http.debian.net/debian",
		distro => "wheezy",
		repository => "main",
		src_repo => false,
		key => "55BE302B" ;

	"wheezy-security" :
		url => "http://security.debian.org/",
		distro => "wheezy/updates",
		repository => "main",
		src_repo => false ;
}
sudo::directive {
	"admin-users" :
		ensure => present,
		content => "david ALL=(ALL) NOPASSWD: ALL\n"
}
group {
	'david' :
		ensure => present ;
}
user {
	'david' :
		ensure => present,
		gid => 'david' ;
}

# of course, the following is not botstrappable, but after a manual intervention, it should lead to a stable, and migratable
# situation.
# for a key roll-over, the git server has to accept both the old and the new key until the puppetmaster has updated itself.
vcsrepo {
	"/srv/puppet/secrets" :
		ensure => latest,
		provider => git,
		source => "ssh://ccnet@dasz.at/srv/dasz/git/puppet-secrets.git",
		owner => puppet,
		group => puppet ;
} -> file {
# vcsrepo does not manage the rights on the directory, so we have to.
# this leaves a little window of opportunity where the secrets are accessible, after
# cloning the repository. Since this should only happen when the puppetmaster is
# re-imaged, I do not believe this to be a problem.
	"/srv/puppet/secrets" :
		ensure => directory,
		mode => 0700,
		owner => puppet,
		group => puppet ;

	"/root/.ssh" :
		ensure => directory,
		mode => 0700,
		owner => root,
		group => root ;

	"/root/.ssh/id_rsa" :
		source => "/srv/puppet/secrets/puppetmaster/id_rsa",
		mode => 0600,
		owner => root,
		group => root ;
}

# for documentation purposes only.
# in production, this will be replaced by a git-hook-pushed mirror
vcsrepo {
	"/srv/puppet/configuration" :
		ensure => latest,
		provider => git,
		source => "git://github.com/DavidS/dasz-configuration.git",
		owner => root,
		group => root ;
}

