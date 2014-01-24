define hosting::mysql_database ($customer, $password = "TESTPASSWORD") {
  mysql::grant { $name:
    mysql_password   => $password,
    mysql_privileges => 'ALL',
    mysql_db         => $name,
    mysql_user       => $customer,
    mysql_host       => 'localhost',
  }
}