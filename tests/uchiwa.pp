# Installs the uchiwa dashboard for sensu
# 192.168.56.10:3000
# uchiwa, uchiwa

package { 'uchiwa':
  ensure => present,
}

file { '/etc/sensu/uchiwa.json':
  ensure  => file,
  content => '
{
  "sensu": [
    {
      "name": "Site1",
      "host": "127.0.0.1",
      "port": 4567,
      "timeout": 5,
      "user": "admin",
      "pass": "secret"
    }
  ],
  "uchiwa": {
    "host": "0.0.0.0",
    "port": 3000,
    "user": "uchiwa",
    "pass": "uchiwa",
    "interval": 5
  }
}',
  require => Package['uchiwa'],
  notify  => Service['uchiwa'],
}

service { 'uchiwa':
  ensure  => running,
  enable  => true,
  require => [ File['/etc/sensu/uchiwa.json'],Package['uchiwa'] ],
}
