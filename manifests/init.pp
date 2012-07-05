
class sensu {

  case $::operatingsystem {
    # add apt sources
    'Debian': { include 'sensu::debian' }
    'Ubuntu': { include 'sensu::debian' }
    default : {}
  }

}
