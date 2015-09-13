# = Class: sensu
#
# Base Sensu class
#
# == Parameters
#
# [*version*]
#   String.  Version of sensu to install
#   Default: latest
#   Valid values: absent, installed, latest, present, [\d\.\-]+
#
# [*sensu_plugin_name*]
#   String.  Name of the sensu-plugin package
#   Default: sensu-plugin
#
# [*sensu_plugin_provider*]
#   String.  Provider used to install the sensu-plugin package
#   Default: undef
#   Valid values: sensu_gem, apt, aptitude, yum
#
# [*sensu_plugin_version*]
#   String.  Version of the sensu-plugin gem to install
#   Default: absent
#   Valid values: absent, installed, latest, present, [\d\.\-]+
#
# [*install_repo*]
#   Boolean.  Whether or not to install the sensu repo
#   Default: true
#   Valid values: true, false
#
# [*enterprise*]
#   Boolean.  Whether or not to install and configure Sensu Enterprise
#   Default: false
#   Valid values: true, false
#
# [*enterprise_dashboard*]
#   Boolean.  Whether or not to install sensu-enterprise-dashboard
#   Default: false
#   Valid values: true, false
#
# [*repo*]
#   String.  Which sensu repo to install
#   Default: main
#   Valid values: main, unstable
#
# [*repo_source*]
#   String.  Location of the yum/apt repo.  Overrides the default location
#   Default: undef

# [*repo_key_id*]
#   String.  The apt GPG key id
#   Default: 8911D8FF37778F24B4E726A218609E3D7580C77F
#
# [*repo_key_source*]
#   String.  URL of the apt GPG key
#   Default: http://repos.sensuapp.org/apt/pubkey.gpg
#
# [*client*]
#   Boolean.  Include the sensu client
#   Default: true
#   Valid values: true, false
#
# [*server*]
#   Boolean.  Include the sensu server
#   Default: false
#   Valid values: true, false
#
# [*api*]
#   Boolean.  Include the sensu api service
#   Default: false
#   Valid values: true, false
#
# [*manage_services*]
#   Boolean.  Manage the sensu services with puppet
#   Default: true
#   Valid values: true, false
#
# [*manage_user*]
#   Boolean.  Manage the sensu user with puppet
#   Default: true
#   Valid values: true, false
#
# [*manage_plugins_dir*]
#   Boolean. Manage the sensu plugins directory
#   Default: true
#   Valid values: true, false
#
# [*rabbitmq_port*]
#   Integer.  Rabbitmq port to be used by sensu
#   Default: 5672
#
# [*rabbitmq_host*]
#   String.  Host running rabbitmq for sensu
#   Default: 'localhost'
#
# [*rabbitmq_user*]
#   String.  Username to connect to rabbitmq with for sensu
#   Default: 'sensu'
#
# [*rabbitmq_password*]
#   String.  Password to connect to rabbitmq with for sensu
#   Default: ''
#
# [*rabbitmq_vhost*]
#   String.  Rabbitmq vhost to be used by sensu
#   Default: 'sensu'
#
# [*rabbitmq_ssl*]
#   Boolean.  Use SSL transport to connect to RabbitMQ.  If rabbitmq_ssl_private_key and/or
#     rabbitmq_ssl_cert_chain are set, then this is enabled automatically.  Set rabbitmq_ssl => true
#     without specifying a private key or cert chain to use SSL transport, but not cert auth.
#   Defaul: false
#   Valid values: true, false
#
# [*rabbitmq_ssl_private_key*]
#   String.  Private key to be used by sensu to connect to rabbitmq. If the value starts with
#     'puppet://' the file will be copied and used.  Also the key itself can be given as the
#     parameter value, or a variable, or using hiera.  Absolute paths will just be used as
#     a file reference, as you'd normally configure sensu.
#   Default: undef
#
# [*rabbitmq_ssl_cert_chain*]
#   String.  Private SSL cert chain to be used by sensu to connect to rabbitmq
#     If the value starts with 'puppet://' the file will be copied and used.   Also the key itself can
#     be given as the parameter value, or a variable, or using hiera. Absolute paths will just be used
#     as a file reference, as you'd normally configure sensu.
#   Default: undef
#
# [*rabbitmq_reconnect_on_error*]
#   Boolean. In the event the connection or channel is closed by RabbitMQ, attempt to automatically
#     reconnect when possible. Default set to fault its not guaranteed to successfully reconnect.
#   Default: false
#   Valid values: true, false
#
# [*redis_host*]
#   String.  Hostname of redis to be used by sensu
#   Default: localhost
#
# [*redis_port*]
#   Integer.  Redis port to be used by sensu
#   Default: 6379
#
# [*redis_password*]
#   String.  Password to be used to connect to Redis
#   Default: undef
#
# [*redis_reconnect_on_error*]
#   Boolean. In the event the connection or channel is closed by Reddis, attempt to automatically
#     reconnect when possible. Default set to fault its not guaranteed to successfully reconnect.
#   Default: false
#   Valid values: true, false
#
# [*redis_db*]
#   Integer.  The Redis instance DB to use/select
#   Default: 0
#
# [*redis_auto_reconnect*]
#   Boolean.  Reconnect to Redis in the event of a connection failure
#   Default: true
#
# [*api_bind*]
#   String.  IP to bind api service
#   Default: 0.0.0.0
#
# [*api_host*]
#   String.  Hostname of the sensu api service
#   Default: localhost
#
# [*api_port*]
#   Integer. Port of the sensu api service
#   Default: 4567
#
# [*api_user*]
#   String.  Password of the sensu api service
#   Default: undef
#
# [*api_password*]
#   String. Password of the sensu api service
#   Default: undef
#
# [*subscriptions*]
#   Array of strings.  Default suscriptions used by the client
#   Default: []
#
# [*client_address*]
#   String.  Address of the client to report with checks
#   Default: $::ipaddress
#
# [*client_name*]
#   String.  Name of the client to report with checks
#   Default: $::fqdn
#
# [*client_custom*]
#   Hash.  Custom client variables
#   Default: {}
#
# [*client_keepalive*]
#   Hash.  Client keepalive config
#   Default: {}
#
# [*safe_mode*]
#   Boolean.  Force safe mode for checks
#   Default: false
#   Valid values: true, false
#
# [*plugins*]
#   String, Array of Strings.  Plugins to install on the node
#   Default: []
#
# [*plugins_dir*]
#   String. Puppet url to plugins directory
#   Default: undef
#
# [*purge*]
#   Boolean or Hash.  If unused plugins, configs, handlers, extensions and mutators should be removed from the system.
#   If set to true, all unused plugins, configs, handlers, extensions and mutators will be removed from the system.
#   If set to a Hash, only unused files of the specified type(s) will be removed from the system.
#   Default: false
#   Valid values: true, false, Hash containing any of the keys 'plugins', 'config', 'handlers', 'extensions', 'mutators'
#   Example value: { config => true, plugins => true }
#
# [*use_embedded_ruby*]
#   Boolean.  If the embedded ruby should be used
#   Default: false
#   Valid values: true, false
#
# [*rubyopt*]
#   String.  Ruby opts to be passed to the sensu services
#   Default: ''
#
# [*gem_path*]
#   String.  Paths to add to GEM_PATH if we need to look for different dirs.
#   Default: ''
#
# [*log_level*]
#   String.  Sensu log level to be used
#   Default: 'info'
#   Valid values: debug, info, warn, error, fatal
#
# [*init_stop_max_wait*]
#   Integer.  Number of seconds to wait for the init stop script to run
#   Default: 10
#
# [*gem_install_options*]
#   Optional configuration to use for the installation of the
#   sensu plugin gem with sensu_gem provider.
#   See: https://docs.puppetlabs.com/references/latest/type.html#package-attribute-install_options
#   Default: undef
#   Example value: [{ '-p' => 'http://user:pass@myproxy.company.org:8080' }]
#
# [*hasrestart*]
#   Boolean. Value of hasrestart attribute for sensu services.
#   If you use your own startup scripts for upstart and want puppet
#   to properly stop and start sensu services when those scripts change,
#   set it to false. See also http://upstart.ubuntu.com/faq.html#reload
#   Default: true
#
class sensu (
  $version                        = 'latest',
  $sensu_plugin_name              = 'sensu-plugin',
  $sensu_plugin_provider          = undef,
  $sensu_plugin_version           = 'absent',
  $install_repo                   = true,
  $enterprise                     = false,
  $enterprise_version             = 'latest',
  $enterprise_user                = undef,
  $enterprise_pass                = undef,
  $enterprise_dashboard           = false,
  $enterprise_dashboard_version   = 'latest',
  $repo                           = 'main',
  $repo_source                    = undef,
  $repo_key_id                    = '8911D8FF37778F24B4E726A218609E3D7580C77F',
  $repo_key_source                = 'http://repos.sensuapp.org/apt/pubkey.gpg',
  $enterprise_repo_key_id         = '910442FF8781AFD0995D14B311AB27E8C3FE3269',
  $client                         = true,
  $server                         = false,
  $api                            = false,
  $manage_services                = true,
  $manage_user                    = true,
  $manage_plugins_dir             = true,
  $rabbitmq_port                  = 5672,
  $rabbitmq_host                  = 'localhost',
  $rabbitmq_user                  = 'sensu',
  $rabbitmq_password              = undef,
  $rabbitmq_vhost                 = 'sensu',
  $rabbitmq_ssl                   = false,
  $rabbitmq_ssl_private_key       = undef,
  $rabbitmq_ssl_cert_chain        = undef,
  $rabbitmq_reconnect_on_error    = false,
  $redis_host                     = 'localhost',
  $redis_port                     = 6379,
  $redis_password                 = undef,
  $redis_reconnect_on_error       = false,
  $redis_db                       = 0,
  $redis_auto_reconnect           = true,
  $api_bind                       = '0.0.0.0',
  $api_host                       = 'localhost',
  $api_port                       = 4567,
  $api_user                       = undef,
  $api_password                   = undef,
  $subscriptions                  = [],
  $client_bind                    = '127.0.0.1',
  $client_port                    = '3030',
  $client_address                 = $::ipaddress,
  $client_name                    = $::fqdn,
  $client_custom                  = {},
  $client_keepalive               = {},
  $safe_mode                      = false,
  $plugins                        = [],
  $plugins_dir                    = undef,
  $purge                          = false,
  $purge_config                   = false,
  $purge_plugins_dir              = false,
  $use_embedded_ruby              = false,
  $rubyopt                        = '',
  $gem_path                       = '',
  $log_level                      = 'info',
  $dashboard                      = false,
  $init_stop_max_wait             = 10,
  $gem_install_options            = undef,
  $hasrestart                     = true,
  $enterprise_dashboard_base_path = undef,
  $enterprise_dashboard_host      = undef,
  $enterprise_dashboard_port      = undef,
  $enterprise_dashboard_refresh   = undef,
  $enterprise_dashboard_user      = undef,
  $enterprise_dashboard_pass      = undef,
  $enterprise_dashboard_github    = undef,
  $enterprise_dashboard_ldap      = undef,

  ### START Hiera Lookups ###
  $extensions                  = {},
  $handlers                    = {},
  $checks                      = {},
  ### END Hiera Lookups ###

){

  validate_bool($client, $server, $api, $install_repo, $enterprise, $enterprise_dashboard, $purge_config, $safe_mode, $manage_services, $rabbitmq_reconnect_on_error, $redis_reconnect_on_error, $hasrestart, $redis_auto_reconnect)

  validate_re($repo, ['^main$', '^unstable$'], "Repo must be 'main' or 'unstable'.  Found: ${repo}")
  validate_re($version, ['^absent$', '^installed$', '^latest$', '^present$', '^[\d\.\-]+$'], "Invalid package version: ${version}")
  validate_re($enterprise_version, ['^absent$', '^installed$', '^latest$', '^present$', '^[\d\.\-]+$'], "Invalid package version: ${version}")
  validate_re($sensu_plugin_version, ['^absent$', '^installed$', '^latest$', '^present$', '^\d[\d\.\-\w]+$'], "Invalid sensu-plugin package version: ${sensu_plugin_version}")
  validate_re($log_level, ['^debug$', '^info$', '^warn$', '^error$', '^fatal$'] )
  if !is_integer($rabbitmq_port) { fail('rabbitmq_port must be an integer') }
  if !is_integer($redis_port) { fail('redis_port must be an integer') }
  if !is_integer($api_port) { fail('api_port must be an integer') }
  if !is_integer($init_stop_max_wait) { fail('init_stop_max_wait must be an integer') }
  if $dashboard { fail('Sensu-dashboard is deprecated, use a dashboard module. See https://github.com/sensu/sensu-puppet#dashboards')}
  if $purge_config { fail('purge_config is deprecated, set the purge parameter to a hash containing `config => true` instead') }
  if $purge_plugins_dir { fail('purge_plugins_dir is deprecated, set the purge parameter to a hash containing `plugins => true` instead') }
  if !is_integer($redis_db) { fail('redis_db must be an integer') }

  # sensu-enterprise supercedes sensu-server and sensu-api
  if ( $enterprise and $api ) or ( $enterprise and $server ) {
    fail('Sensu Enterprise: sensu-enterprise replaces sensu-server and sensu-api')
  }
  # validate enterprise repo creds
  if ( $enterprise or $enterprise_dashboard ) and $install_repo {
    validate_string($enterprise_user, $enterprise_pass)
    if $enterprise_user == undef or $enterprise_pass == undef {
      fail('The Sensu Enterprise repos require both enterprise_user and enterprise_pass to be set')
    }
  }

  # Ugly hack for notifications, better way?
  # Put here to avoid computing the conditionals for every check
  if $client and $server and $api {
    $check_notify = [ Class['sensu::client::service'], Class['sensu::server::service'], Class['sensu::api::service'] ]
  } elsif $client and $server {
    $check_notify = [ Class['sensu::client::service'], Class['sensu::server::service'] ]
  } elsif $client and $api {
    $check_notify = [ Class['sensu::client::service'], Class['sensu::api::service'] ]
  } elsif $server and $api {
    $check_notify = [ Class['sensu::server::service'], Class['sensu::api::service'] ]
  } elsif $server {
    $check_notify = Class['sensu::server::service']
  } elsif $client {
    $check_notify = Class['sensu::client::service']
  } elsif $api {
    $check_notify = Class['sensu::api::service']
  } else {
    $check_notify = []
  }

  # Because you can't reassign a variable in puppet and we need to set to
  # false if you specify a directory, we have to use another variable.
  if $plugins_dir {
    $_manage_plugins_dir = false
  } else {
    $_manage_plugins_dir = $manage_plugins_dir
  }

  if is_bool($purge) {
    # If purge is a boolean, we either purge everything or purge nothing
    $_purge_plugins    = $purge
    $_purge_config     = $purge
    $_purge_handlers   = $purge
    $_purge_extensions = $purge
    $_purge_mutators   = $purge
  } else {
    # If purge is not a boolean, it must be a hash
    validate_hash($purge)
    # Default anything not specified to false
    $default_purge_hash = { plugins => false, config => false, handlers => false, extensions => false, mutators => false }
    $full_purge_hash = merge($default_purge_hash, $purge)
    validate_bool($full_purge_hash['plugins'], $full_purge_hash['config'], $full_purge_hash['handlers'], $full_purge_hash['extensions'], $full_purge_hash['mutators'])
    # Check that all keys are valid
    $invalid_keys = difference(keys($purge), keys($default_purge_hash))
    if !empty($invalid_keys) {
      fail("Invalid keys for purge parameter: ${invalid_keys}")
    }

    $_purge_plugins    = $full_purge_hash['plugins']
    $_purge_config     = $full_purge_hash['config']
    $_purge_handlers   = $full_purge_hash['handlers']
    $_purge_extensions = $full_purge_hash['extensions']
    $_purge_mutators   = $full_purge_hash['mutators']
  }

  # Create resources from hiera lookups
  create_resources('::sensu::extension', $extensions)
  create_resources('::sensu::handler', $handlers)
  create_resources('::sensu::check', $checks)

  # Include everything and let each module determine its state.  This allows
  # transitioning to purged config and stopping/disabling services
  anchor { 'sensu::begin': } ->
  class { '::sensu::package': } ->
  class { '::sensu::enterprise::package': } ->
  class { '::sensu::rabbitmq::config': } ->
  class { '::sensu::api::config': } ->
  class { '::sensu::redis::config': } ->
  class { '::sensu::client::config': } ->
  class { '::sensu::client::service':
    hasrestart => $hasrestart,
  } ->
  class { '::sensu::api::service':
    hasrestart => $hasrestart,
  } ->
  class { '::sensu::server::service':
    hasrestart => $hasrestart,
  } ->
  class { '::sensu::enterprise::service': } ->
  class { '::sensu::enterprise::dashboard': } ->
  anchor {'sensu::end': }

  if $plugins_dir {
    sensu::plugin { $plugins_dir: type => 'directory' }
  } else {
    sensu::plugin { $plugins: install_path => '/etc/sensu/plugins' }
  }

}
