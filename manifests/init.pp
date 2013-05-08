# = Class: sensu
#
# Base Sensu class
#
# == Parameters
#
# None.
#

class sensu (
  $rabbitmq_password        = '',
  $server                   = 'false',
  $client                   = 'true',
  $version                  = 'latest',
  $install_repo             = 'true',
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
  $subscriptions            = [],
  $client_address           = $::ipaddress,
  $client_name              = $::fqdn,
  $plugins                  = [],
  $purge_config             = false,
  $use_embedded_ruby        = false,
  $safe_mode                = false,
){

  anchor {'sensu::begin': }
  anchor {'sensu::end': }

  Anchor['sensu::begin'] ->
  Class['sensu::package'] ->
  Class['sensu::rabbitmq']

  Class['sensu::rabbitmq'] ->
  Class['sensu::server'] ~>
  Class['sensu::service::server'] ->
  Anchor['sensu::end']

  Class['sensu::rabbitmq'] ->
  Class['sensu::client'] ~>
  Class['sensu::service::client'] ->
  Anchor['sensu::end']

  if $server == 'true' or $server == true {
    if $client == 'true' or $client == true {
      Class['sensu::service::server'] ~> Class['sensu::service::client']
      $notify_services = [ Class['sensu::service::client'], Class['sensu::service::server'] ]
    } else {
      $notify_services = Class['sensu::service::server']
    }
  } elsif $client == 'true' or $client == true {
    $notify_services = Class['sensu::service::client']
  } else {
    $notify_services = []
  }

  class { 'sensu::package':
    version           => $version,
    install_repo      => $install_repo,
    notify_services   => $notify_services,
    purge_config      => $purge_config,
    use_embedded_ruby => $use_embedded_ruby,
  }

  class { 'sensu::rabbitmq':
    ssl_cert_chain  => $rabbitmq_ssl_cert_chain,
    ssl_private_key => $rabbitmq_ssl_private_key,
    port            => $rabbitmq_port,
    host            => $rabbitmq_host,
    user            => $rabbitmq_user,
    password        => $rabbitmq_password,
    vhost           => $rabbitmq_vhost,
    notify_services => $notify_services,
    purge_config    => $purge_config,
  }

  class { 'sensu::server':
    redis_host          => $redis_host,
    redis_port          => $redis_port,
    api_host            => $api_host,
    api_port            => $api_port,
    dashboard_host      => $dashboard_host,
    dashboard_port      => $dashboard_port,
    dashboard_user      => $dashboard_user,
    dashboard_password  => $dashboard_password,
    enabled             => $server,
    purge_config        => $purge_config,
  }

  class { 'sensu::service::server': enabled => $server }

  class { 'sensu::client':
    address       => $client_address,
    subscriptions => $subscriptions,
    client_name   => $client_name,
    enabled       => $client,
    purge_config  => $purge_config,
    safe_mode     => $safe_mode,
  }

  class { 'sensu::service::client': enabled => $client }

  sensu::plugin { $plugins: install_path => '/etc/sensu/plugins'}

}
