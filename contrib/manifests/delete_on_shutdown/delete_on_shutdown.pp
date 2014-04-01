#
#
class sensu::shutdowndelete {
  $sensuhost = $sensu::rabbitmq_host

  file { 
    '/etc/init.d/sensu_delete':
    mode    => '0555',
    content => template("${module_name}/sensu_delete.erb");
  } ~>
  exec { 'sensu-delete-update-rc.d':
    command     => "/usr/sbin/update-rc.d sensu_delete start 10 0 1 6 .",
    refreshonly => true
  }
}
