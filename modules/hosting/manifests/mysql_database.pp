define hosting::mysql_database ($customer, $base_dir, $admin_user, $password) {
  $private_cnf = "${base_dir}/apps/.my.${name}.cnf"

  mysql::grant { $name:
    mysql_password   => $password,
    mysql_privileges => 'ALL',
    mysql_db         => $name,
    mysql_user       => $admin_user,
    mysql_host       => 'localhost',
  }

  file { $private_cnf:
    content => template('hosting/mysql.user.cnf.erb'),
    mode    => 0600,
    owner   => $admin_user;
  }

  cron { "hosting::mysql_database::${name}::backup":
    command => "/usr/bin/mysqldump --defaults-extra-file=${private_cnf} ${name} | gzip -r > ${base_dir}/backups/${name}-$(date --iso=s).mysql_backup.gz",
    user    => $admin_user,
    minute  => fqdn_rand(59, "hosting::pg_database::${name}"),
    hour    => 3;
  }
}