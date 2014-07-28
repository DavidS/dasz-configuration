# manages all resources for a single customer
#
# Files are usually confined to /srv/${name}
# Configuration goes to the respective daemons
#
# The admin user has full rights into everything
# The app user can read all "application" files and write to selected directories
# Normal users can only read and write their respective home directories
#
# type is a documentation flag
define hosting::customer (
  $admin_user,
  $admin_fullname,
  $type            = 'none',
  $users           = 'none',
  $domains,
  $vhosts          = {
  }
  ,
  $certs           = 'none',
  $cert_base_path  = 'puppet:///secrets/',
  $db_password     = 'none',
  $mysql_databases = 'none',
  $pg_databases    = 'none',) {
  if ($mysql_databases != 'none' and $db_password == 'none') {
    fail("Hosting::Customer[${name}]: has mysql database, but no db_password")
  }

  if ($pg_databases != 'none' and $db_password == 'none') {
    fail("Hosting::Customer[${name}]: has pg database, but no db_password")
  }

  $admin_user_escaped = inline_template('<%= @admin_user.gsub(/-/, "\\x2d") %>')

  include hosting, postgresql, mysql

  $customer = $name
  $base_dir = "/srv/${customer}"
  $admin_group = "${customer}_admins"
  $all_group = "${customer}_all"

  create_resources("hosting::domain", $domains, {
    admin_user  => $admin_user,
    admin_group => $admin_group,
    base_dir    => $base_dir,
  }
  )

  if (is_hash($vhosts)) {
    create_resources("hosting::external_vhost", $vhosts, {
      admin_user  => $admin_user,
      admin_group => $admin_group,
      base_dir    => $base_dir,
    }
    )
  }

  if (is_hash($users)) {
    create_resources("hosting::pobox", $users, {
      base_dir    => $base_dir,
      all_group   => $all_group,
      admin_user  => $admin_user,
      admin_group => $admin_group,
    }
    )
  }

  if $db_password != 'none' {
    hosting::mysql_database { $customer:
      customer   => $customer,
      base_dir   => $base_dir,
      admin_user => $admin_user,
      password   => $db_password;
    }

    if (is_hash($mysql_databases)) {
      create_resources("hosting::mysql_database", $mysql_databases, {
        customer   => $customer,
        base_dir   => $base_dir,
        admin_user => $admin_user,
        password   => $db_password
      }
      )
    }

    hosting::pg_database { $customer:
      customer   => $customer,
      base_dir   => $base_dir,
      admin_user => $admin_user,
      password   => $db_password;
    }

    if (is_hash($pg_databases)) {
      create_resources("hosting::pg_database", $pg_databases, {
        customer   => $customer,
        base_dir   => $base_dir,
        admin_user => $admin_user,
        password   => $db_password
      }
      )
    }
  }

  if (is_hash($certs)) {
    create_resources("hosting::cert", $certs, {
      base_path => $cert_base_path,
    }
    )
  }

  # add the admin group to the admin user
  Pobox[$admin_user] {
    groups +> [$admin_group] }

  group { [$admin_group, $all_group]: ensure => present }

  exec { "hosting::${customer}::useradd::home_workaround":
    command => "/bin/mkdir -p ${base_dir}/home",
    creates => "${base_dir}/home";
  } -> User <| |>

  file {
    # externals have to poke here
    [
      $base_dir,
      "${base_dir}/mail",
      ]:
      ensure => directory,
      mode   => 2751,
      owner  => $admin_user,
      group  => $all_group;

    # directories accessible to all
    ["${base_dir}/home"]:
      ensure => directory,
      mode   => 2751,
      owner  => $admin_user,
      group  => $all_group;

    # admin only directories
    [
      "${base_dir}/home/${admin_user}",
      "${base_dir}/home/${admin_user}/bin",
      ]:
      ensure => directory,
      mode   => 2750,
      owner  => $admin_user,
      group  => $admin_group;

    # admin group only directories
    [
      "${base_dir}/etc",
      "${base_dir}/etc/nginx",
      "${base_dir}/etc/nginx/conf.d",
      "${base_dir}/etc/nginx/sites-enabled",
      "${base_dir}/ssl",
      "${base_dir}/tmp",
      "${base_dir}/www",
      ]:
      ensure => directory,
      mode   => 2770,
      owner  => $admin_user,
      group  => $admin_group;

    "${base_dir}/home/${admin_user}/bin/update-apps":
      content => template("hosting/update-apps.erb"),
      mode    => 0750,
      owner   => $admin_user,
      group   => $admin_group;

    # app directories
    "${base_dir}/apps":
      ensure => directory,
      mode   => 2771,
      owner  => $admin_user,
      group  => $admin_group;

    [
      "${base_dir}/backups",
      "${base_dir}/log",
      ]:
      ensure => directory,
      mode   => 2770,
      owner  => $admin_user,
      group  => $admin_group;

    # app directories, need to be o+x to allow access to nginx.sock
    ["${base_dir}/run",]:
      ensure => directory,
      mode   => 2771,
      owner  => $admin_user,
      group  => $admin_group;

    # the admin user's home contains the systemd user config
    [
      "${base_dir}/home/${admin_user}/.config",
      "${base_dir}/home/${admin_user}/.config/systemd",
      "${base_dir}/home/${admin_user}/.config/systemd/user",
      "${base_dir}/home/${admin_user}/.config/systemd/user/default.target.wants",
      ]:
      ensure => directory,
      mode   => 2770,
      owner  => $admin_user,
      group  => $admin_group;

    "${base_dir}/home/${admin_user}/.config/systemd/user/default.target":
      ensure  => present,
      source  => 'puppet:///modules/hosting/default.target',
      replace => false,
      mode    => 0660,
      owner   => $admin_user,
      group   => $admin_group,
      before  => Service["user@${admin_user_escaped}.service"];

    "${base_dir}/etc/nginx/nginx.conf":
      content => template("hosting/nginx.customer.conf.erb"),
      replace => false,
      mode    => 0660,
      owner   => $admin_user,
      group   => $admin_group,
      before  => Service["user@${admin_user_escaped}.service"];
  }

  hosting::customer_service { "${customer}::nginx":
    base_dir        => $base_dir,
    admin_user      => $admin_user,
    admin_group     => $admin_group,
    service_name    => 'nginx',
    service_content => template('hosting/nginx.service.erb'),
    enable          => true,
  }

  exec { "hosting::${customer}::enable-apps-linger":
    command => "/bin/systemd-loginctl enable-linger ${admin_user}",
    onlyif  => "/bin/systemctl > /dev/null",
    unless  => "/bin/systemd-loginctl show-user ${admin_user}",
    require => [User[$admin_user], Exec['dbus-restart'], Package['systemd']];
  }

  # enable user@ service manually as systemd cannot do so (bug?)
  $user_service_file = "/etc/systemd/system/multi-user.target.wants/user@${admin_user_escaped}.service"

  file { $user_service_file:
    ensure  => symlink,
    target  => '/lib/systemd/system/user@.service',
    before  => Service["user@${admin_user_escaped}.service"],
    require => Package['systemd'],
    notify  => Exec["systemd-reload"];
  }

  service { "user@${admin_user_escaped}.service":
    ensure    => running,
    provider  => systemd,
    require   => [
      Exec["hosting::${customer}::enable-apps-linger"],
      File["${base_dir}/home/${admin_user}/.config/systemd/user/default.target"],
      Exec["systemd-reload"]],
    subscribe => File[$user_service_file];
  }
}
