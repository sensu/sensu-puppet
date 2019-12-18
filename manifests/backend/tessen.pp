# @summary Manage tessen phone home
# @api private
#
class sensu::backend::tessen {
  include sensu::backend

  if $sensu::backend::tessen_ensure == 'present' {
    $command = 'sensuctl tessen opt-in'
    $match = 'true' # lint:ignore:quoted_booleans
  } else {
    $command = 'sensuctl tessen opt-out --skip-confirm'
    $match = 'false' # lint:ignore:quoted_booleans
  }

  exec { $command:
    path    => '/usr/bin:/bin:/usr/sbin:/sbin',
    onlyif  => "sensuctl tessen info --format json | grep 'opt_out' | grep -q ${match}",
    require => [
      Sensuctl_configure['puppet'],
      Sensu_user['admin'],
    ],
  }

}
