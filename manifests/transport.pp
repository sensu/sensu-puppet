# Class: sensu::transport
#
# Configure Sensu Transport
#
class sensu::transport {

  if $caller_module_name != $module_name {
    fail("Use of private function ${name} by ${caller_module_name}")
  }

  if $sensu::transport_type != 'redis' {
    $ensure = 'absent'
  } else {
    $ensure = 'present'
  }

  $transport_type_hash = {
    'transport' => {
      'name'               => $sensu::transport_type,
      'reconnect_on_error' => true,
    },
  }

  file { "${sensu::conf_dir}/transport.json":
    ensure  => $ensure,
    owner   => 'sensu',
    group   => 'sensu',
    mode    => '0440',
    content => inline_template("<%= JSON.pretty_generate(@transport_type_hash) %>"),
    notify  => $sensu::check_notify,
  }
}
