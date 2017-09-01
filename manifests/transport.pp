# @summary Configures Sensu transport
#
# Configure Sensu Transport
#
class sensu::transport {

  if $::osfamily == 'Darwin' {
    $ensure = present
  }
  else {
    if $::sensu::transport_type != 'redis' {
      $ensure = 'absent'
    } else {
      $ensure = 'present'
    }
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
