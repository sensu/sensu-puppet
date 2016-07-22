# = Class: sensu::rabbitmq::config
#
# Sets the Sensu rabbitmq config
#
class sensu::rabbitmq::config {

  if $caller_module_name != $module_name {
    fail("Use of private class ${name} by ${caller_module_name}")
  }

  if $sensu::_purge_config and !$sensu::server and !$sensu::client and !$sensu::enterprise {
    $ensure = 'absent'
  } else {
    $ensure = 'present'
  }

  $ssl_dir = "${sensu::etc_dir}/ssl"

  if $sensu::rabbitmq_ssl_cert_chain or $sensu::rabbitmq_ssl_private_key {
    file { $ssl_dir:
      ensure  => directory,
      owner   => $sensu::user,
      group   => $sensu::group,
      mode    => '0755',
      require => Package['sensu'],
    }

    # if provided a cert chain, and its a puppet:// URI, source file form the
    # the URI provided
    if $sensu::rabbitmq_ssl_cert_chain and $sensu::rabbitmq_ssl_cert_chain =~ /^puppet:\/\// {
      file { "${ssl_dir}/cert.pem":
        ensure  => file,
        source  => $sensu::rabbitmq_ssl_cert_chain,
        owner   => $sensu::user,
        group   => $sensu::group,
        mode    => $sensu::file_mode,
        require => File[$ssl_dir],
        before  => File["${sensu::conf_dir}/rabbitmq.json"],
      }

      $ssl_cert_chain = "${ssl_dir}/cert.pem"
    # else provided a cert chain, and the variable actually contains the cert,
    # create the file with conents of the variable
    } elsif $sensu::rabbitmq_ssl_cert_chain and  $sensu::rabbitmq_ssl_cert_chain =~ /BEGIN CERTIFICATE/ {
      file { "${ssl_dir}/cert.pem":
        ensure  => file,
        content => $sensu::rabbitmq_ssl_cert_chain,
        owner   => $sensu::user,
        group   => $sensu::group,
        mode    => $sensu::file_mode,
        require => File[$ssl_dir],
        before  => File["${sensu::conf_dir}/rabbitmq.json"],
      }

      $ssl_cert_chain = "${ssl_dir}/cert.pem"
    # else set the cert to value passed in wholesale, usually this is
    # a raw file path
    } else {
      $ssl_cert_chain = $sensu::rabbitmq_ssl_cert_chain
    }

    # if provided private key, and its a puppet:// URI, source file from the
    # URI provided
    if $sensu::rabbitmq_ssl_private_key and $sensu::rabbitmq_ssl_private_key =~ /^puppet:\/\// {
      file { "${ssl_dir}/key.pem":
        ensure  => file,
        source  => $sensu::rabbitmq_ssl_private_key,
        owner   => $sensu::user,
        group   => $sensu::group,
        mode    => $sensu::file_mode,
        require => File[$ssl_dir],
        before  => File["${sensu::conf_dir}/rabbitmq.json"],
      }

      $ssl_private_key = '/etc/sensu/ssl/key.pem'
    # else provided private key, and the variable actually contains the key,
    # create file with contents of the variable
    } elsif $sensu::rabbitmq_ssl_private_key and $sensu::rabbitmq_ssl_private_key =~ /BEGIN RSA PRIVATE KEY/ {
      file { "${ssl_dir}/key.pem":
        ensure  => file,
        content => $sensu::rabbitmq_ssl_private_key,
        owner   => $sensu::user,
        group   => $sensu::group,
        mode    => $sensu::file_mode,
        require => File[$ssl_dir],
        before  => File["${sensu::conf_dir}/rabbitmq.json"],
      }

      $ssl_private_key = '/etc/sensu/ssl/key.pem'
    # else set the private key to value passed in wholesale, usually this is
    # a raw file path
    } else {
      $ssl_private_key = $sensu::rabbitmq_ssl_private_key
    }

    $enable_ssl = true
  } else {
    $ssl_cert_chain = undef
    $ssl_private_key = undef
    $enable_ssl = $sensu::rabbitmq_ssl
  }


  if ! $sensu::rabbitmq_cluster {
    sensu_rabbitmq_config { $::fqdn:
      ensure             => $ensure,
      port               => $sensu::rabbitmq_port,
      host               => $sensu::rabbitmq_host,
      user               => $sensu::rabbitmq_user,
      password           => $sensu::rabbitmq_password,
      vhost              => $sensu::rabbitmq_vhost,
      ssl_transport      => $enable_ssl,
      ssl_cert_chain     => $ssl_cert_chain,
      ssl_private_key    => $ssl_private_key,
      reconnect_on_error => $sensu::rabbitmq_reconnect_on_error,
      prefetch           => $sensu::rabbitmq_prefetch,
      base_path          => $sensu::conf_dir,
    }


    file { "${sensu::conf_dir}/rabbitmq.json":
      ensure => $ensure,
      owner  => $sensu::user,
      group  => $sensu::group,
      mode   => $sensu::file_mode,
      before => Sensu_rabbitmq_config[$::fqdn],
    }
  } elsif ! $sensu::rabbitmq_cluster_custom {
    file { "${sensu::conf_dir}/rabbitmq.json":
      ensure  => $ensure,
      content => template('sensu/rabbitmq.conf.erb'),
      owner   => $sensu::user,
      group   => $sensu::group,
      mode    => $sensu::file_mode,
    }
  } else {
    file { "${sensu::conf_dir}/rabbitmq.json":
      ensure  => $ensure,
      content => template('sensu/rabbitmq.conf_custom.erb'),
      owner   => $sensu::user,
      group   => $sensu::group,
      mode    => $sensu::file_mode,
    }
  }
}
