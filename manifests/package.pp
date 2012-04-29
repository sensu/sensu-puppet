class sensu::package {
  package { 'sensu':
    ensure => latest,
  }
}
