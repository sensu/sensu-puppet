# = Class: sensu::rabbitmq::config
#
# Sets the Sensu rabbitmq config
#
class sensu::rabbitmq::config {

  if $caller_module_name != $module_name {
    fail("Use of private class ${name} by ${caller_module_name}")
  }

  if $sensu::purge_config and !$sensu::server and !$sensu::client {
    $ensure = 'absent'
  } else {
    $ensure = 'present'
  }

  if $sensu::rabbitmq_ssl_cert_chain {
    file { '/etc/sensu/ssl':
      ensure  => directory,
      owner   => 'sensu',
      group   => 'sensu',
      mode    => '0755',
      require => Package['sensu'],
    }

    if $sensu::rabbitmq_ssl_cert_chain =~ /^puppet:\/\// {
      file { '/etc/sensu/ssl/cert.pem':
        ensure  => present,
        source  => $sensu::rabbitmq_ssl_cert_chain,
        owner   => 'sensu',
        group   => 'sensu',
        mode    => '0444',
        require => File['/etc/sensu/ssl'],
        before  => Sensu_rabbitmq_config[$::fqdn],
      }

      $ssl_cert_chain = '/etc/sensu/ssl/cert.pem'
    } else {
      $ssl_cert_chain = $sensu::rabbitmq_ssl_cert_chain
    }

    if $sensu::rabbitmq_ssl_private_key =~ /^puppet:\/\// {
      file { '/etc/sensu/ssl/key.pem':
        ensure  => present,
        source  => $sensu::rabbitmq_ssl_private_key,
        owner   => 'sensu',
        group   => 'sensu',
        mode    => '0440',
        require => File['/etc/sensu/ssl'],
        before  => Sensu_rabbitmq_config[$::fqdn],
      }

      $ssl_private_key = '/etc/sensu/ssl/key.pem'
    } else {
      $ssl_private_key = $sensu::rabbitmq_ssl_private_key
    }
  } else {
    $ssl_cert_chain = undef
    $ssl_private_key = undef
  }

  file { '/etc/sensu/conf.d/rabbitmq.json':
    ensure  => $ensure,
    owner   => 'sensu',
    group   => 'sensu',
    mode    => '0440',
    before  => Sensu_rabbitmq_config[$::fqdn],
  }

  sensu_rabbitmq_config { $::fqdn:
    ensure          => $ensure,
    port            => $sensu::rabbitmq_port,
    host            => $sensu::rabbitmq_host,
    user            => $sensu::rabbitmq_user,
    password        => $sensu::rabbitmq_password,
    vhost           => $sensu::rabbitmq_vhost,
    ssl_transport   => $sensu::rabbitmq_ssl,
    ssl_cert_chain  => $ssl_cert_chain,
    ssl_private_key => $ssl_private_key,
  }

}
