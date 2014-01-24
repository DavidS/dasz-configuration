define hosting::pg_database ($customer, $base_dir, $app_user, $password = "TESTPASSWORD") {
  postgresql::dbcreate { $name:
    role     => $app_user,
    encoding => 'UTF-8',
    locale   => 'de_AT.UTF-8',
    template => 'template0',
    password => $password,
  }

  postgresql::hba { "hba_${name}_local":
    ensure   => 'present',
    type     => 'local',
    database => $name,
    user     => $app_user,
    address  => '',
    method   => 'peer',
  }

  cron { "hosting::pg_database::${name}::backup":
    command => "/usr/bin/pg_dump --file=${base_dir}/backups/${name}-$(date --iso=s).pg_backup --format=custom --compress=6 ${name}",
    user    => $app_user,
    minute  => fqdn_rand(59, "hosting::pg_database::${name}"),
    hour    => 3;
  }
}