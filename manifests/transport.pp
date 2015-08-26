# = Class: sensu::transport
#
# Configure Sensu Transport
#
class sensu::transport {

  if $caller_module_name != $module_name {
    fail("Use of private class ${name} by ${caller_module_name}")
  }

  if $sensu::_purge_config and !$sensu::server and !$sensu::api {
    $ensure = 'absent'
  } else {
    $ensure = 'present'
  }

  $transport_type = {
    'transport' => {
      'name' => "$::sensu::transport_type"
    }
  }

  # type of sensu transport
  file { '/etc/sensu/conf.d/transport.json':
    ensure  => $ensure,
    owner   => 'sensu',
    group   => 'sensu',
    mode    => '0440',
    content => inline_template("<%= JSON.pretty_generate(@transport_type) %>"),
    notify  => $::sensu::check_notify,
  }

}
