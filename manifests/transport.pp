# @summary Configures Sensu transport
#
# Configures Sensu transport
#
# @param ensure If to create or remove the transport.json file
#
class sensu::transport (
  Enum['present','absent'] $ensure = 'present',
) {

  $transport_type_hash = {
    'transport' => {
      'name'               => $::sensu::transport_type,
      'reconnect_on_error' => $::sensu::transport_reconnect_on_error,
    },
  }

  file { "${sensu::conf_dir}/transport.json":
    ensure  => $ensure,
    owner   => 'sensu',
    group   => 'sensu',
    mode    => '0440',
    content => inline_template('<%= JSON.pretty_generate(@transport_type_hash) %>'),
    notify  => $::sensu::check_notify,
  }
}
