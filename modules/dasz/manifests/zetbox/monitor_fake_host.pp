define dasz::zetbox::monitor_fake_host ($folder) {
  include munin

  $fqdn = $name
  $folder_prefix = $folder ? {
    ''      => '',
    default => "${folder};",
  }

  @@file { "${munin::include_dir}/${fqdn}.conf":
    ensure  => $munin::manage_file,
    path    => "${munin::include_dir}/${fqdn}.conf",
    mode    => $munin::config_file_mode,
    owner   => $munin::config_file_owner,
    group   => $munin::config_file_group,
    content => template("dasz/zetbox/fake_host.erb"),
    tag     => "munin_host_${munin::magic_tag}",
  }
}