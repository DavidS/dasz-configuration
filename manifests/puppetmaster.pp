
class {
  "apt":
    force_sources_list_d => true;

  #  "foreman":
  #    url           => "http://${::fqdn}",
  #    puppet_server => $::fqdn,
  #    enc           => false, # TODO: enable this
  #    reports       => true,
  #    facts         => true,
  #    storeconfigs  => false,
  #    db            => postgresql,
  #    db_user       => 'foreman';
  "ntp":
  ;

  "openssh": # TODO: add host key management
  ;

  "postgresql":
  ;

  "puppet":
    template      => 'site/puppetmaster/puppet.conf.erb',
    mode          => 'server',
    server        => 'puppetmaster.dasz.at', # can be configured more globally
    runmode       => 'manual', # change this later (to cron), see also croninterval, croncommand
    db            => 'puppetdb',
    db_server     => $fqdn, # TODO: should be default?
    db_port       => 8081, # TODO: should be default for puppetdb?
    dns_alt_names => '',
    require       => [Vcsrepo["/srv/puppet/configuration"], Apt::Repository["wheezy-puppetlabs"]];

  "puppetdb":
    db_type => 'postgresql',
    db_host => 'localhost',
    db_user => 'puppetdb',
    require => Apt::Repository["wheezy-puppetlabs"];

  "puppetdb::postgresql":
    require => Apt::Repository["wheezy-puppetlabs"];

  "rsyslog":
  ;

  "sudo":
  ;
}

apt::repository {
  "wheezy":
    url        => "http://http.debian.net/debian",
    distro     => "wheezy",
    repository => "main",
    src_repo   => false,
    key        => "55BE302B";

  "wheezy-security":
    url        => "http://security.debian.org/",
    distro     => "wheezy/updates",
    repository => "main",
    src_repo   => false;

  "wheezy-puppetlabs":
    url        => "http://apt.puppetlabs.com",
    distro     => "wheezy",
    repository => "main",
    src_repo   => false,
    key        => "4BD6EC30",
    key_url    => "https://apt.puppetlabs.com/pubkey.gpg";
}

sudo::directive { "admin-users":
  ensure  => present,
  content => "david ALL=(ALL) NOPASSWD: ALL\n"
}

group { 'david': ensure => present; }

user { 'david':
  ensure => present,
  gid    => 'david';
}

package { "git":
  ensure => installed,
  before => Vcsrepo["/srv/puppet/configuration"];
}

sshkey {
  "dasz.at":
    type => 'ssh-rsa',
    key  => 'AAAAB3NzaC1yc2EAAAABIwAAAQEA7fm/+pwGWYvPGvdstm3FfIWaDQtVFVHUySqmZRXRjXQk/UDClzmQ12aqu3e+2rgHA1GVcgEg1/MZeS1LgIfyTM9Z2IhjP4dWlR+xpZbsI6z0L6HGK4UAhT5wuIunltSj1hZAZbm5kU2bvuc/GuzDa7VF8iW1SOyop5PVgM3Jl/JoScSjaSz+eGXYX97Ixd8frj12lu40jGmOaUNsmsj5S1P4Nb57dQj4qsLT3jHUqBQyje/Cp2R0hLCBZaipow7zmoT8grNlN8Rnc6OesArtos0w3hErhDaPfKCYeXOIDZFRoDIA/xXqujFivEWRaSdccJvon46xWuhf+Hbd1OWY/Q=='
    ;

  "github.com":
    type => 'ssh-rsa',
    key  => 'AAAAB3NzaC1yc2EAAAABIwAAAQEAq2A7hRGmdnm9tUDbO9IDSwBK6TbQa+PXYPCPy6rbTrTtw7PHkccKrpp0yVhp5HdEIcKr6pLlVDBfOLX9QUsyCOV0wzfjIJNlGEYsdlLJizHhbn2mUjvSAHQqZETYP81eFzLQNnPHt4EVVUh7VfDESU84KezmD5QlWpXLmvU31/yMf+Se8xhHTvKSCZIFImWwoG6mbUoWf9nzpIoaSjB+weqqUUmpaaasXVal72J+UX2B+2RPW3RcT0eOzQgqlJL3RKrTJvdsjE3JEAvGq3lGHSZXy28G3skua2SmVi/w4yCE6gbODqnTWlg7+wC604ydGXA8VJiS5ap43JXiUFFAaQ=='
    ;
}

# of course, the following is not botstrappable, but after a manual intervention, it should lead to a stable, and migratable
# situation.
# for a key roll-over, the git server has to accept both the old and the new key until the puppetmaster has updated itself.
# vcsrepo { "/srv/puppet/secrets":
#  ensure   => latest,
#  provider => git,
#  source   => "ssh://ccnet@dasz.at/srv/dasz/git/puppet-secrets.git",
#  owner    => puppet,
#  group    => puppet,
#  require  => Sshkey["dasz.at"];
# } ->

file {
  # vcsrepo does not manage the rights on the directory, so we have to.
  # this leaves a little window of opportunity where the secrets are accessible, after
  # cloning the repository. Since this should only happen when the puppetmaster is
  # re-imaged, I do not believe this to be a problem.
  "/srv/puppet/secrets":
    ensure => directory,
    mode   => 0700,
    owner  => puppet,
    group  => puppet;

  "/root/.ssh":
    ensure => directory,
    mode   => 0700,
    owner  => root,
    group  => root;

  "/root/.ssh/id_rsa":
    source => "/srv/puppet/secrets/puppetmaster/id_rsa",
    mode   => 0600,
    owner  => root,
    group  => root;
}

# for documentation purposes only.
# in production, this will be replaced by a git-hook-pushed mirror
vcsrepo { "/srv/puppet/configuration":
  ensure   => latest,
  provider => git,
  source   => "git://github.com/DavidS/dasz-configuration.git",
  owner    => root,
  group    => root,
  require  => Sshkey["github.com"];
}

