# This class is used by update_apps to manage the common resources for a customer
# It is always run in user context!
class hosting::update_apps {
  exec { "reload nginx":
    command     => "/bin/systemctl --user reload nginx.service",
    refreshonly => true;
  }
}