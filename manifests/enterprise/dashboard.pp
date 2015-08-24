# = Class: sensu::enterprise::dashboard
#
# Installs the Sensu Enterprise Dashboard
class sensu::enterprise::dashboard {

  anchor { 'sensu::enterprise::dashboard::begin': } ->
  class { '::sensu::enterprise::dashboard::package': } ->
  class { '::sensu::enterprise::dashboard::config': } ->
  class { '::sensu::enterprise::dashboard::service': } ->
  anchor { 'sensu::enterprise::dashboard::end': }

}
