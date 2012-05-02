define sensu::server(
                      $rabbitmq_password,
                      $rabbitmq_port            = '5671',
                      $rabbitmq_host            = 'localhost',
                      $rabbitmq_user            = 'sensu',
                      $rabbitmq_vhost           = '/sensu',
                      $rabbitmq_ssl_private_key = '',
                      $rabbitmq_ssl_cert_chain  = '',
                      $redis_host               = 'localhost',
                      $redis_port               = '6379',
                      $api_host                 = 'localhost',
                      $api_port                 = '4567',
                      $dashboard_host           = $::ipaddress,
                      $dashboard_port           = '8080',
                      $dashboard_user           = 'admin',
                      $dashboard_password       = 'secret',
                      $ensure                   = 'present'
                    ) {
  include sensu::package

  if !defined(Sensu_rabbitmq_config[$::fqdn]) {
    if $rabbitmq_ssl_cert_chain != '' {
      Sensu_rabbitmq_config {
        ssl_cert_chain => $rabbitmq_ssl_cert_chain,
      }
    }

    if $rabbitmq_ssl_private_key != '' {
      Sensu_rabbitmq_config {
        ssl_private_key => $rabbitmq_ssl_private_key,
      }
    }

    sensu_rabbitmq_config { $::fqdn:
      port     => $rabbitmq_port,
      host     => $rabbitmq_host,
      user     => $rabbitmq_user,
      password => $rabbitmq_password,
      vhost    => $rabbitmq_vhost,
    }
  }

  sensu_redis_config { $::fqdn:
    host => $redis_host,
    port => $redis_port,
  }

  sensu_api_config { $::fqdn:
    host => $api_host,
    port => $api_port,
  }

  sensu_dashboard_config { $::fqdn:
    host     => $dashboard_host,
    port     => $dashboard_port,
    user     => $dashboard_user,
    password => $dashboard_password,
  }

  Service {
    ensure => running,
    enable => true,
  }

  service {
    'sensu-server':
      require => [
        Sensu_rabbitmq_config[$::fqdn],
        Sensu_redis_config[$::fqdn],
      ];
    'sensu-api':
      require => [
        Sensu_rabbitmq_config[$::fqdn],
        Sensu_api_config[$::fqdn],
        Service['sensu-server'],
      ];
    'sensu-dashboard':
      require => [
        Sensu_rabbitmq_config[$::fqdn],
        Sensu_dashboard_config[$::fqdn],
        Service['sensu-api'],
      ];
  }

  sensu::handler { 'default':
    type    => 'pipe',
    command => '/etc/sensu/handlers/default',
  }

  Sensu_check_config<<| |>>
}
