# Class: examplesensu::server
#
#
class examplesensu::server {

  package { 'redis-server':
    ensure => installed,
  }
  file {
    '/etc/rabbitmq/ssl/cacert.pem':
      ensure => file,
      owner  => root,
      group  => root,
      mode   => '0644',
      source => "puppet:///modules/${module_name}/server/cacert.pem";
    '/etc/rabbitmq/ssl/cert.pem':
      ensure => file,
      owner  => root,
      group  => root,
      mode   => '0644',
      source => "puppet:///modules/${module_name}/server/cert.pem";
    '/etc/rabbitmq/ssl/key.pem':
      ensure => file,
      owner  => root,
      group  => root,
      mode   => '0644',
      source => "puppet:///modules/${module_name}/server/key.pem";
  }
  class { '::rabbitmq':
    ssl                      => true,
    ssl_verify               => 'verify_peer',
    ssl_fail_if_no_peer_cert => true,
    ssl_cacert               => '/etc/rabbitmq/ssl/cacert.pem',
    ssl_cert                 => '/etc/rabbitmq/ssl/cert.pem',
    ssl_key                  => '/etc/rabbitmq/ssl/key.pem',
    stomp_port               => 61613,
    config_stomp             => true,
    
  } ->
  rabbitmq_vhost { '/sensu':
    ensure => present,
  }
  rabbitmq_user_permissions { 'guest@/sensu':
    configure_permission => '.*',
    read_permission      => '.*',
    write_permission     => '.*',
  }
  rabbitmq_user { 'sensu':
    admin    => true,
    password => 'abc123',
  }
  rabbitmq_user_permissions { 'sensu@/sensu':
    configure_permission => '.*',
    read_permission      => '.*',
    write_permission     => '.*',
  }


  class { 'sensu':
    rabbitmq_password        => 'abc123',
    server                   => true,
    dashboard                => true,
    api                      => true,
    rabbitmq_port            => '5671',
    rabbitmq_ssl_cert_chain  => 'puppet:///modules/${module_name}/client/cert.pem',
    rabbitmq_ssl_private_key => "puppet:///modules/${module_name}/client/key.pem",
    subscriptions            => 'companyx',
  }


# Setup a email handler for Amazon SES
  sensu::handler { 'mailer':
    command                       => '/etc/sensu/plugins/mailer.rb',
    source                        => "puppet:///modules/${module_name}/handlers/mailer.rb",
    config                        => {
      'mail_from'                 => 'sensu@example.com',
      'mail_to'                   => 'admin@example.com',
      'smtp_address'              => 'email-smtp.us-east-1.amazonaws.com',
      'smtp_port'                 => '587',
      'smtp_domain'               => 'example.com',
      'smtp_username'             => 'SES_USERNAME',
      'smtp_password'             => 'SES_SECRETKEY',
      'smtp_enable_starttls_auto' => true
    }
  }

  sensu::handler { 'debug':
    command => 'tee -a /tmp/sensu_handler_logs',
  #  mutator =>  "only_check_output",
  }

  class {'examplesensu::checks':}
  class {'examplesensu::plugins':}


}
