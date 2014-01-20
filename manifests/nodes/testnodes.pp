# this class is reused between vagrants direct puppet provisioner and local puppet agent --test runs
# the latter are necessary to test storeconfigs
class puppetmaster_example_org {
  class {
    'dasz::defaults':
      location             => vagrant,
      puppet_agent         => false,
      apt_dater_manager    => true,
      apt_dater_key        => 'AAAAB3NzaC1yc2EAAAADAQABAAABAQCsg5F+Ml0AngmMMKrEr4YW5OP2qe2gpY9pfg0iFwjXnTqh8HZK63+HqmWGrGUt7mPZZMYOnGGkpYDmksqgHZscm6NGIxOvEWg52ZfcBUxIgKkoqZHIMSf/zhCifGxmepMHO/hb7wQKzwuc+XjzOwt70qwkhEDs6flKfYnagwxFC6YvrAeW5h2cwHDQb9To6ryITSvbhbUHNIwKGpYbz0Bqx5sdn2Kca80FsW8ImRmph4albnVMqDTdLCUvZoPhl/z6BCqduFpdPGGkfxicSmOBPRHuQOgTwTAh3aMR0lmnKfNX/wHqYgaWoU+ow+846ob70N949Oy05B/1Dc109Xfh',
      apt_dater_secret_key => template('site/puppetmaster/apt-dater-test-secret'),
      primary_ip           => '192.168.50.4',
      force_nullmailer     => true;

    "foreman":
      install_mode           => all,
      url                    => "https://${::fqdn}",
      puppet_server          => $::fqdn,
      authentication         => true,
      enc                    => true,
      reports                => true,
      facts                  => true,
      storeconfigs           => false,
      passenger              => true,
      unattended             => true,
      db                     => postgresql,
      db_server              => 'localhost',
      db_user                => 'foreman',
      db_password            => 'muhblah',
      repo_flavour           => stable,
      install_proxy          => true,
      proxy_feature_puppet   => true,
      proxy_feature_puppetca => true,
      proxy_feature_tftp     => true;

    "postgresql":
    ;

    "puppet":
      template        => 'site/puppetmaster/puppet-vagrant.conf.erb',
      mode            => 'server',
      server          => 'puppetmaster.example.org', # can be configured more globally
      runmode         => 'manual', # change this later (to cron), see also croninterval, croncommand
      nodetool        => 'foreman',
      db              => 'puppetdb',
      db_server       => $::fqdn, # TODO: should be default?
      db_port         => 8081, # TODO: should be default for puppetdb?
      dns_alt_names   => '',
      autosign        => true,
      inventoryserver => '', # do not try to store facts anywhere
      # server_service_autorestart => true,
      require         => Class["dasz::defaults"];

    "puppetdb":
      db_type     => 'postgresql',
      db_host     => 'localhost',
      db_user     => 'puppetdb',
      db_password => 'muhblah', # local installation cannot depend on some secrets repo
      require     => Class["dasz::defaults"];

    'dasz::snips::systemd':
      grub_timeout => 0;
  }

  host { 'workstation': ip => '192.168.50.1'; }
}

node 'puppetmaster.example.org' {
  include puppetmaster_example_org
}

# testagent in vagrant
# this can be used to test various stuff deployed via the puppetmaster
node 'testagent.example.org' {
  $testkey = 'OS/Yq8CnQ+XnsvwS783zCwHtTOtCuzPZhjM/sBZdTHTutLxxv/ahpPBOPPTrBWwSDeNL5BuW+IEcZF42c3V9WA=='

  class {
    'dasz::defaults':
      location             => vagrant,
      distro               => wheezy,
      puppet_agent         => false,
      apt_dater_key        => 'AAAAB3NzaC1yc2EAAAADAQABAAABAQCsg5F+Ml0AngmMMKrEr4YW5OP2qe2gpY9pfg0iFwjXnTqh8HZK63+HqmWGrGUt7mPZZMYOnGGkpYDmksqgHZscm6NGIxOvEWg52ZfcBUxIgKkoqZHIMSf/zhCifGxmepMHO/hb7wQKzwuc+XjzOwt70qwkhEDs6flKfYnagwxFC6YvrAeW5h2cwHDQb9To6ryITSvbhbUHNIwKGpYbz0Bqx5sdn2Kca80FsW8ImRmph4albnVMqDTdLCUvZoPhl/z6BCqduFpdPGGkfxicSmOBPRHuQOgTwTAh3aMR0lmnKfNX/wHqYgaWoU+ow+846ob70N949Oy05B/1Dc109Xfh',
      apt_dater_secret_key => 'unused',
      ssh_port             => 22,
      primary_ip           => '192.168.50.50',
      force_nullmailer     => true;

    "puppet":
      mode       => 'client',
      server     => 'puppetmaster.example.org',
      runmode    => 'cron',
      audit_only => true,
      require    => Class['dasz::defaults'];

    'dasz::snips::systemd':
      grub_timeout => 0;
  }

  $customers = {
    'dasz'         => {
      admin_user     => 'david-dasz',
      admin_fullname => 'David Schmitt',
      users          => {
        dasz1      => {
          uid     => 1666,
          comment => "Testuser",
        }
        ,
        david-dasz => {
          uid     => 1003,
          comment => "Test admin",
        }
        ,
      }
      ,
      domains        => {
        'dasz.at'   => {
        }
        ,
        'zetbox.at' => {
        }
        ,
      }
    }
    ,
    'example'      => {
      admin_user     => 'example',
      admin_fullname => 'John Doe',
      users          => {
        example        => {
          comment        => "test admin user",
        }
      }
      ,
      domains        => {
        'example.com' => {
        }
        ,
        'example.org' => {
        }
        ,
        'very-long-subdomain.of.example.net' => {
        }
        ,
      }
    }
  }

  create_resources(hosting::customer, $customers)

  hosting::nginx_user_snip {
    "@@test1@@":
      basedomain => 'dasz.at',
      customer   => 'dasz',
      admin_user => $customers['dasz']['admin_user'],
      type       => 'mono',
      local_name => 'testapp_name',
      location   => '/testapp_loc';

    "@@test2@@":
      basedomain => 'dasz.at',
      subdomain  => 'foo',
      customer   => 'dasz',
      admin_user => $customers['dasz']['admin_user'],
      type       => 'mono',
      local_name => 'testapp_name',
      location   => '/foo_testapp_loc';

    "@@test3@@":
      basedomain => 'dasz.at',
      subdomain  => 'www',
      customer   => 'dasz',
      admin_user => $customers['dasz']['admin_user'],
      type       => 'php5',
      local_name => 'php_appname',
      location   => '/phpapp_loc';
  }

  # testing cowbuilding mono3
  package { "cowbuilder": ensure => installed; }

  $debian_mirror = 'kvmhost.dasz:3142'
  $basedir = '/var/cache/pbuilder'

  $dist = 'wheezy'
  $arch = 'amd64'

  file { # cache dir for dist/arch
    "${basedir}/${dist}-${arch}":
      ensure  => directory,
      mode    => 0755,
      owner   => root,
      group   => root,
      require => Package["cowbuilder"];

    "/etc/pbuilderrc":
      content => template("dasz/jenkins/pbuilderrc.erb"),
      mode    => 0644,
      owner   => root,
      group   => root;
  }

  exec { "cowbuilder create ${dist}-${arch}":
    command => "/usr/sbin/cowbuilder --create --basepath /var/cache/pbuilder/${dist}-${arch}/base.cow --distribution ${dist} --debootstrapopts --arch --debootstrapopts ${arch}",
    require => [File["${basedir}/${dist}-${arch}"], File["/etc/pbuilderrc"]],
    creates => "${basedir}/${dist}-${arch}/base.cow";
  }

  apt::repository { "experimental":
    url        => "http://kvmhost.dasz:3142/debian",
    distro     => experimental,
    repository => "main",
    src_repo   => true;
  }

}

node 'monitor.example.org' {
  class {
    'dasz::defaults':
      location             => vagrant,
      puppet_agent         => false,
      apt_dater_key        => 'AAAAB3NzaC1yc2EAAAADAQABAAABAQCsg5F+Ml0AngmMMKrEr4YW5OP2qe2gpY9pfg0iFwjXnTqh8HZK63+HqmWGrGUt7mPZZMYOnGGkpYDmksqgHZscm6NGIxOvEWg52ZfcBUxIgKkoqZHIMSf/zhCifGxmepMHO/hb7wQKzwuc+XjzOwt70qwkhEDs6flKfYnagwxFC6YvrAeW5h2cwHDQb9To6ryITSvbhbUHNIwKGpYbz0Bqx5sdn2Kca80FsW8ImRmph4albnVMqDTdLCUvZoPhl/z6BCqduFpdPGGkfxicSmOBPRHuQOgTwTAh3aMR0lmnKfNX/wHqYgaWoU+ow+846ob70N949Oy05B/1Dc109Xfh',
      apt_dater_secret_key => 'unused',
      munin_node           => false,
      force_nullmailer     => true;

    "puppet":
      mode    => 'client',
      server  => 'puppetmaster.example.org',
      runmode => 'cron',
      require => Class['dasz::defaults'];

    'nginx':
    ;

    'munin':
      folder            => vagrant,
      server            => '192.168.50.5',
      address           => '192.168.50.5',
      server_local      => true,
      include_dir_purge => true,
      graph_strategy    => cgi;

    'munin::cgi_systemd':
    ;

    'dasz::snips::systemd':
      grub_timeout => 0;
  }

  file {
    "/etc/munin/munin-conf.d/update_rate.conf":
      content => "update_rate 60\n",
      mode    => 0644,
      owner   => root,
      group   => root,
      notify  => Service["munin-fastcgi.service"];

    "/etc/munin/munin-conf.d/graph_width.conf":
      content => "graph_width 600\n",
      mode    => 0644,
      owner   => root,
      group   => root,
      notify  => Service["munin-fastcgi.service"];

    "/etc/nginx/conf.d/server_name_redirect.conf":
      content => "server_name_in_redirect off;\n",
      mode    => 0644,
      owner   => root,
      group   => root,
      notify  => Service["nginx"];

    "/etc/nginx/sites-enabled/default":
      content => "
server {
        root /usr/share/nginx/www;
        index index.html index.htm;

        server_name localhost;

        location /munin {
                alias /var/cache/munin/www;
        }
        location /munin/static/ {
                alias /etc/munin/static/;
                expires modified +1w;
        }
        location ^~ /munin-cgi/munin-cgi-graph/ {
                fastcgi_split_path_info ^(/munin-cgi/munin-cgi-graph)(.*);
                fastcgi_param PATH_INFO \$fastcgi_path_info;
                fastcgi_pass unix:/var/run/munin/fcgi-graph.sock;
                include fastcgi_params;
        }

}
",
      mode    => 0644,
      owner   => root,
      group   => root,
      notify  => Service["nginx"];
  }

  # required for the zetbox_ plugins
  package { "libwww-perl": ensure => installed }

  jenkins_zetbox_snip {
    'dasz-prod':
      url => "https://office.dasz.at/dasz/PerfMon.facade";

    'zetbox-nh':
      url => "http://jenkins:7007/zetbox/develop/PerfMon.facade";
    #    'zetbox_zetbox-ef':
    #      url => "http://build01-win7/jenkins/zetbox-develop/PerfMon.facade";
  }
}

# use
#     sudo puppet agent --test --server puppetmaster.example.org --certname workstation.example.org --ssldir
#     /var/lib/puppet/vagrantssl
# to receive these default host names
node 'workstation.example.org' {
  host {
    'puppetmaster.example.org':
      ip => '192.168.50.4';

    'monitor.example.org':
      ip => '192.168.50.5';

    'testagent.example.org':
      ip => '192.168.50.50';
  }
}

class experimental {
  apt::repository { "experimental":
    url        => $dasz::defaults::location ? {
      'hetzner' => "http://mirror.hetzner.de/debian/packages",
      default   => 'http://http.debian.net/debian',
    },
    distro     => experimental,
    repository => "main",
    src_repo   => false,
    key        => "55BE302B";
  }
}