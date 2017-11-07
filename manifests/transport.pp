# @summary Configures Sensu transport
#
# Configure Sensu Transport
#
class sensu::transport {

  if $::sensu::transport_type == 'redis'
  or $::sensu::transport_type == 'rabbitmq' {
    $ensure = 'present'
  } else {
    $ensure = 'absent'
  }

  $transport_type_hash = {
    'transport' => {
      'name'               => $::sensu::transport_type,
      'reconnect_on_error' => $::sensu::transport_reconnect_on_error,
    },
  }

  case $::osfamily {
    'windows': {
      $user      = $::sensu::user
      $group     = $::sensu::group
      $file_mode = undef
    }
    default: {
      $user      = 'sensu'
      $group     = 'sensu'
      $file_mode = '0440'
    }
  }

  file { "${sensu::conf_dir}/transport.json":
    ensure  => $ensure,
    owner   => $user,
    group   => $group,
    mode    => $file_mode,
    content => inline_template('<%= JSON.pretty_generate(@transport_type_hash) %>'),
    notify  => $::sensu::check_notify,
  }
}
