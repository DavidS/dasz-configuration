define hosting::pg_database ($customer, $password = "TESTPASSWORD") {
  postgresql::dbcreate { $name:
    role     => $customer,
    password => $password,
    encoding => 'utf-8',
    locale   => 'de_AT.utf-8',
  }
}