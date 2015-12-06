define hosting::ssl_cert (
  $ca           = none,
  $cert_file,
  $cert_content = '',
  $cert_source  = '',
  $cert_mode    = 0644,
  $cert_owner   = 'root',
  $cert_group   = 'root',
  $key_file,
  $key_content  = '',
  $key_source   = '',
  $key_mode     = 0600,
  $key_owner    = '',
  $key_group    = '') {
  file { $key_file:
    mode    => $key_mode,
    owner   => $key_owner ? {
      ''      => $cert_owner,
      default => $key_owner,
    },
    group   => $key_group ? {
      ''      => $cert_group,
      default => $key_group,
    },
    content => $key_content ? {
      ''      => undef,
      default => $key_content
    },
    source  => $key_source ? {
      ''      => undef,
      default => $key_source
    },
  }

  if $ca == 'sslmate' {
    file {
      $cert_file:
        mode    => $cert_mode,
        owner   => $cert_owner,
        group   => $cert_group,
        content => $cert_content ? {
          ''      => undef,
          default => $cert_content
        },
        source  => $cert_source ? {
          ''      => undef,
          default => $cert_source
        },
    }
  } else {
    concat { $cert_file:
      mode  => $cert_mode,
      owner => $cert_owner,
      group => $cert_group;
    }
  
    concat::fragment { "${name}.crt.pem#certificate":
      target  => $cert_file,
      order   => 10,
      content => $cert_content ? {
        ''      => undef,
        default => $cert_content
      },
      source  => $cert_source ? {
        ''      => undef,
        default => $cert_source
      }
    }
  
    if ($ca != self and $ca != none) {
      concat::fragment { "${name}.crt.pem#bundle":
        target => $cert_file,
        order  => 90,
        source => "puppet:///modules/hosting/ssl/${ca}.bundle.pem";
      }
    }
  }
}
