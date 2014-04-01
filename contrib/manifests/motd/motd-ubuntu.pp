# Class: examplesensu::motd
#
#
class examplesensu::motd-ubuntu {
  $sensuhost = $sensu::rabbitmq_host

  file {
    '/usr/local/bin/sensu_report':
      mode   => '0555',
      source => 'puppet:///modules/kenshosensu/sensu_report';
    '/etc/update-motd.d/95-sensu-report':
      mode    => '0555',
      content => template("${module_name}/95-sensu-report.erb");
    # '/etc/update-motd.d/10-help-text':
    #   ensure => absent;
    # '/etc/update-motd.d/51-cloudguest':
    #   ensure => absent;
  }
}
