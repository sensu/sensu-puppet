# = Class: sensu::enterprise::dashboard
#
# Installs the Sensu Enterprise Dashboard
class sensu::enterprise::dashboard (
  $hasrestart = true,
) {

  anchor { 'sensu::enterprise::dashboard::begin': }
  -> class { '::sensu::enterprise::dashboard::package': }
  -> class { '::sensu::enterprise::dashboard::config': }
  -> class { '::sensu::enterprise::dashboard::service':
    hasrestart => $hasrestart,
  }
  -> anchor { 'sensu::enterprise::dashboard::end': }

}
