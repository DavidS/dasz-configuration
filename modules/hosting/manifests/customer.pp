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
  $users,
  $domains,
  $mysql_databases = [],
  $pg_databases    = [],) {
  include hosting, postgresql, mysql

  $customer = $name
  $base_dir = "/srv/${customer}"
  $admin_group = "${customer}_admins"
  $all_group = "${customer}_all"
  $app_user = "${customer}_app"

  create_resources("hosting::domain", $domains, {
    admin_user  => $admin_user,
    base_dir    => $base_dir,
    admin_group => $admin_group,
    app_user    => $app_user,
  }
  )

  create_resources("hosting::pobox", $users, {
    gid       => $all_group,
    base_dir  => $base_dir,
    all_group => $all_group
  }
  )

  hosting::mysql_database {
    $customer:
      customer => $customer,
      base_dir => $base_dir,
      app_user => $app_user;

    $mysql_databases:
      customer => $customer,
      base_dir => $base_dir,
      app_user => $app_user;
  }

  hosting::pg_database {
    $customer:
      customer => $customer,
      base_dir => $base_dir,
      app_user => $app_user;

    $pg_databases:
      customer => $customer,
      base_dir => $base_dir,
      app_user => $app_user;
  }

  # add the admin group to the admin user
  Pobox[$admin_user] {
    groups +> [$admin_group] }

  group { [$admin_group, $all_group]: ensure => present }

  exec { "hosting::${customer}::useradd::home_workaround":
    command => "/bin/mkdir -p ${base_dir}/home",
    creates => "${base_dir}/home";
  } -> User <| |>

  user { $app_user:
    gid        => $admin_group,
    comment    => "${admin_fullname}",
    home       => "${base_dir}/apps",
    managehome => true,
    groups     => [$all_group],
  }

  file {
    $base_dir:
      ensure => directory,
      mode   => 2751,
      owner  => $admin_user,
      group  => $all_group;

    # directories accessible to all
    ["${base_dir}/home"]:
      ensure => directory,
      mode   => 2750,
      owner  => $admin_user,
      group  => $all_group;

    # admin only directories
    [
      "${base_dir}/home/${admin_user}",
      "${base_dir}/home/${admin_user}/bin",
      "${base_dir}/etc",
      "${base_dir}/etc/nginx",
      "${base_dir}/etc/nginx/conf.d",
      "${base_dir}/etc/nginx/sites-enabled",
      "${base_dir}/mail",
      "${base_dir}/ssl",
      "${base_dir}/www",
      ]:
      ensure => directory,
      mode   => 2750,
      owner  => $admin_user,
      group  => $admin_group;

    "${base_dir}/home/${admin_user}/bin/update-apps":
      content => template("hosting/update-apps.erb"),
      replace => false,
      mode    => 0750,
      owner   => $admin_user,
      group   => $admin_group;

    # app directories
    [
      "${base_dir}/backups",
      "${base_dir}/log",
      ]:
      ensure => directory,
      mode   => 2770,
      owner  => $app_user,
      group  => $admin_group;

    # app directories, need to be o+x to allow access to nginx.sock
    ["${base_dir}/run",]:
      ensure => directory,
      mode   => 2771,
      owner  => $app_user,
      group  => $admin_group;

    # the app user's home contains the systemd user config
    [
      "${base_dir}/apps",
      "${base_dir}/apps/.config",
      "${base_dir}/apps/.config/systemd",
      "${base_dir}/apps/.config/systemd/user",
      "${base_dir}/apps/.config/systemd/user/default.target.wants",
      ]:
      ensure => directory,
      mode   => 2770,
      owner  => $app_user,
      group  => $admin_group;

    "${base_dir}/apps/.config/systemd/user/default.target":
      ensure  => present,
      source  => 'puppet:///modules/hosting/default.target',
      replace => false,
      mode    => 0660,
      owner   => $admin_user,
      group   => $admin_group,
      before  => Service["user@${app_user}.service"];

    "${base_dir}/etc/nginx/nginx.conf":
      content => template("hosting/nginx.customer.conf.erb"),
      replace => false,
      mode    => 0660,
      owner   => $admin_user,
      group   => $admin_group,
      before  => Service["user@${app_user}.service"];
  }

  hosting::customer_service { "${customer}::nginx":
    base_dir        => $base_dir,
    app_user        => $app_user,
    admin_user      => $admin_user,
    admin_group     => $admin_group,
    service_name    => 'nginx',
    service_content => template('hosting/nginx.service.erb'),
    enable          => true,
  }

  exec { "hosting::${customer}::enable-apps-linger":
    command => "/bin/systemd-loginctl enable-linger ${app_user}",
    onlyif  => "/bin/systemctl > /dev/null",
    unless  => "/bin/systemd-loginctl show-user ${app_user}",
    require => [User[$app_user], Exec['dbus-restart'], Package['systemd']];
  }

  # enable user@ service manually as systemd cannot do so (bug?)
  file { "/etc/systemd/system/multi-user.target.wants/user@${app_user}.service":
    ensure  => symlink,
    target  => '/lib/systemd/system/user@.service',
    before  => Service["user@${app_user}.service"],
    require => Package['systemd'],
    notify  => Exec["systemd-reload"];
  }

  service { "user@${app_user}.service":
    ensure    => running,
    provider  => systemd,
    require   => [Exec["hosting::${customer}::enable-apps-linger"], File["${base_dir}/apps/.config/systemd/user/default.target"]],
    subscribe => Exec["systemd-reload"];
  }
}
