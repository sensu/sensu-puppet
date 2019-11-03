if $facts['os']['family'] == 'windows' {
  $install_source = 'https://s3-us-west-2.amazonaws.com/sensu.io/sensu-go/5.14.1/sensu-go_5.14.1_windows_amd64.zip'
} else {
  $install_source = undef
}

class { '::sensu::cli':
  install_source => $install_source,
  url_host       => 'sensu-backend.example.com',
}
