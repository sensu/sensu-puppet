
# @summary Configures Sensu transport
#
# Configure Sensu Transport
#
class sensu::transport {

  if $::sensu::transport_type != 'redis' {
    $ensure = $::osfamily ? {
      'Darwin' => 'present',
      default  => 'absent'
    }
  } else {
    $ensure = 'present'
  }

  $transport_type_hash = {
    'transport' => {
      'name'               => $::sensu::transport_type,
      'reconnect_on_error' => $::sensu::transport_reconnect_on_error,
    },
  }

  file { "${sensu::conf_dir}/transport.json":
    ensure  => $ensure,
    owner   => $::sensu::user,
    group   => $::sensu::group,
    mode    => '0440',
    content => inline_template('<%= JSON.pretty_generate(@transport_type_hash) %>'),
    notify  => $::sensu::check_notify,
  }
}
