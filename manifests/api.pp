# @summary Manage Sensu API
#
# Class to manage the Sensu API.
#
# @example
#   include sensu::api
#
class sensu::api {
  include sensu

  sensu_api_config { 'sensu':
    url                 => $sensu::api_url,
    username            => 'admin',
    password            => $sensu::password,
    validate_namespaces => $sensu::validate_namespaces,
  }

  sensu_api_validator { 'sensu':
    sensu_api_server => $sensu::api_host,
    sensu_api_port   => $sensu::api_port,
    use_ssl          => $sensu::use_ssl,
  }
}
