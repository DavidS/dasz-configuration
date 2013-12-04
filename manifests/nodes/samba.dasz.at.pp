node 'samba.dasz.at' {
  class {
    'dasz::defaults':
      location          => hetzner,
      admin_users       => false, # collides with local ldap setup
      munin_smart_disks => ['sda'],
      force_nullmailer  => true;

    'dasz::snips::systemd':
    ;
  }

  # eth0 is openvpn to office
  # eth1 is nat to hetzner
  # avoid using office line for upstream
  file { "/etc/dhcp/dhclient-enter-hooks.d/no-default-route-via-tech21":
    content => "if [ \"\$interface\" = \"eth0\" ]; then
  case \$reason in
    BOUND|RENEW|REBIND|REBOOT)
      unset new_routers
      ;;
  esac
fi

",
    mode    => 0644,
    owner   => root,
    group   => root;
  }
}
