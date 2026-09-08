if $facts['os']['family'] == 'windows' {
  # URL pattern: https://s3-us-west-2.amazonaws.com/sensu.io/sensu-go/<version>/sensu-go_<version>_windows_amd64.zip
  # Find current release at: https://github.com/sensu/sensu-go/releases
  $install_source = 'https://s3-us-west-2.amazonaws.com/sensu.io/sensu-go/6.14.2/sensu-go_6.14.2_windows_amd64.zip'
} else {
  $install_source = undef
}

class { 'sensu':
  api_host => 'sensu-backend.example.com',
}
class { 'sensu::cli':
  install_source => $install_source,
  configure      => false,
}
