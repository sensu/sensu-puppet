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
        before  => Sensu_rabbitmq_config[$::fqdn],
      }

      $ssl_cert_chain = '/etc/sensu/ssl/cert.pem'
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
        before  => Sensu_rabbitmq_config[$::fqdn],
      }

      $ssl_cert_chain = '/etc/sensu/ssl/cert.pem'
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
        before  => Sensu_rabbitmq_config[$::fqdn],
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
        before  => Sensu_rabbitmq_config[$::fqdn],
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

  file { "${sensu::conf_dir}/rabbitmq.json":
    ensure => $ensure,
    owner  => $sensu::user,
    group  => $sensu::group,
    mode   => $sensu::file_mode,
    before => Sensu_rabbitmq_config[$::fqdn],
  }

  $has_cluster = !($sensu::rabbitmq_cluster == undef or $sensu::rabbitmq_cluster == [])
  $host = $has_cluster ? { false => $sensu::rabbitmq_host, true => undef, }
  $port = $has_cluster ? { false => $sensu::rabbitmq_port, true => undef, }
  $user = $has_cluster ? { false => $sensu::rabbitmq_user, true => undef, }
  $password = $has_cluster ? { false => $sensu::rabbitmq_password, true => undef, }
  $vhost = $has_cluster ? { false => $sensu::rabbitmq_vhost, true => undef, }
  $ssl_transport = $has_cluster ? { false => $enable_ssl, true => undef, }
  $cert_chain = $has_cluster ? { false => $ssl_cert_chain, true => undef, }
  $private_key = $has_cluster ? { false => $ssl_private_key, true => undef, }
  $reconnect_on_error = $has_cluster ? { false => $sensu::rabbitmq_reconnect_on_error, true => undef, }
  $prefetch = $has_cluster ? { false => $sensu::rabbitmq_prefetch, true => undef, }
  $base_path = $has_cluster ? { false => $sensu::conf_dir, true => undef, }
  $cluster = $has_cluster ? { true => $sensu::rabbitmq_cluster, false => undef, }

  sensu_rabbitmq_config { $::fqdn:
    ensure             => $ensure,
    port               => $port,
    host               => $host,
    user               => $user,
    password           => $password,
    vhost              => $vhost,
    ssl_transport      => $ssl_transport,
    ssl_cert_chain     => $cert_chain,
    ssl_private_key    => $private_key,
    reconnect_on_error => $reconnect_on_error,
    prefetch           => $prefetch,
    base_path          => $base_path,
    cluster            => $cluster,
  }

}
