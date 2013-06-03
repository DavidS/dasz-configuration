class dasz::snips::locales ($default_language = "en_US:en", $default_locale = "en_US.UTF-8", $utf8_locales = ['en_US', 'de_AT']) {
  package { "locales": ensure => installed; }

  file {
    "/etc/locale.gen":
      content => template("dasz/locale.gen.erb"),
      mode    => 0644,
      owner   => root,
      group   => root,
      require => Package['locales'];

    "/etc/default/locale":
      content => template("dasz/default.locale.erb"),
      mode    => 0644,
      owner   => root,
      group   => root,
      require => Package['locales'];
  }

  exec { "/usr/sbin/locale-gen":
    refreshonly => true,
    subscribe   => File['/etc/locale.gen'];
  }
}