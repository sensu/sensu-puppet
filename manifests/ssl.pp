# @summary Private class to manage sensu SSL resources
# @api private
#
class sensu::ssl {
  include ::sensu

  file { 'sensu_ssl_dir':
    ensure  => 'directory',
    path    => $::sensu::ssl_dir,
    purge   => $::sensu::ssl_dir_purge,
    recurse => $::sensu::ssl_dir_purge,
    force   => $::sensu::ssl_dir_purge,
    owner   => $::sensu::user,
    group   => $::sensu::group,
    mode    => '0700',
  }

  file { 'sensu_ssl_ca':
    ensure    => 'file',
    path      => "${::sensu::ssl_dir}/ca.crt",
    owner     => $::sensu::user,
    group     => $::sensu::group,
    mode      => '0644',
    show_diff => false,
    source    => $::sensu::ssl_ca_source,
  }

  if $::sensu::ssl_add_ca_trust {
    ensure_packages(['openssl'])
    include ::trusted_ca
    trusted_ca::ca { 'sensu-ca':
      source  => "${::sensu::ssl_dir}/ca.crt",
      require => [
        Package['openssl'],
        File['sensu_ssl_ca'],
      ],
    }
  }
}
