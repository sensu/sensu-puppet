if $facts['os']['family'] == 'windows' {
  $install_source = 'https://s3-us-west-2.amazonaws.com/sensu.io/sensu-go/5.20.1/sensu-go_5.20.1_windows_amd64.zip'
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
