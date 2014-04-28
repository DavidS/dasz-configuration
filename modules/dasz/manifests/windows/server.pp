# a windows server
class dasz::windows::server {
  class { 'dasz::windows':
    nagios_notifications       => true,
    nagios_notification_period => 'business-hrs';
  }
}
