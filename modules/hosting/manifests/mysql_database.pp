define hosting::mysql_database ($customer, $base_dir, $app_user, $password = "TESTPASSWORD") {
  $private_cnf = "${base_dir}/apps/.my.${name}.cnf"

  mysql::grant { $name:
    mysql_password   => $password,
    mysql_privileges => 'ALL',
    mysql_db         => $name,
    mysql_user       => $app_user,
    mysql_host       => 'localhost',
  }

  file { $private_cnf:
    content => template('hosting/mysql.user.cnf.erb'),
    mode    => 0600,
    owner   => $app_user;
  }

  cron { "hosting::mysql_database::${name}::backup":
    command => "/usr/bin/mysqldump --defaults-extra-file=${private_cnf} ${name} | gzip -r > ${base_dir}/backups/${name}-$(date --iso=s).mysql_backup.gz",
    user    => $app_user,
    minute  => fqdn_rand(59, "hosting::pg_database::${name}"),
    hour    => 3;
  }
}