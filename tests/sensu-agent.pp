if $facts['os']['family'] == 'windows' {
  $package_source = 'https://s3-us-west-2.amazonaws.com/sensu.io/sensu-go/5.7.0/sensu-go-agent_5.7.0.2380_en-US.x64.msi'
} else {
  $package_source = undef
}

class { '::sensu::agent':
  backends       => ['sensu-backend.example.com:8081'],
  package_source => $package_source,
}
