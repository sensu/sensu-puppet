# = Class: sensu
#
# Base Sensu class
#
# == Parameters
#
# [*version*]
#   String.  Version of sensu to install.  Defaults to `installed` to support
#   Windows MSI packaging and to avoid surprising upgrades.
#   Default: installed
#   Valid values: absent, installed, latest, present, [\d\.\-el]+
#
# [*sensu_plugin_name*]
#   String.  Name of the sensu-plugin package. Refers to the sensu-plugin rubygem
#   Not the community sensu-plugins community scripts.
#   Default: sensu-plugin
#
# [*sensu_plugin_provider*]
#   String.  Provider used to install the sensu-plugin package. Refers to the
#   sensu-plugin rubygem, not the sensu-plugins community scripts.  On windows,
#   defaults to `gem`, all other platforms defaults to `undef`
#   Default: undef
#   Valid values: sensu_gem, apt, aptitude, yum
#
# [*sensu_plugin_version*]
#   String.  Version of the sensu-plugin gem to install. Refers to the sensu-plugin
#   rubygem, not the sensu-plugins community scripts
#   Default: installed
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
# [*manage_repo*]
#   String. Wether or not to manage apt/yum repositories
#   Default: true
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
#   Default: EE15CFF6AB6E4E290FDAB681A20F259AEB9C94BB
#
# [*repo_key_source*]
#   String.  URL of the apt GPG key
#   Default: https://sensu.global.ssl.fastly.net/apt/pubkey.gpg
#
# [*repo_release*]
#   String. Release for the apt source. Only set this if you want to run
#   packages from another release, which is not supported by Sensu. Only works
#   with systems that use apt.
#   Default: $::lsbdistcodename
#
# [*spawn_limit*]
#   Integer.  Tune concurrency of the sensu-server pipe handler and the
#   sensu-client check execution.  This setting should not need to be tuned
#   except in specific situations, e.g. when there are a large number of JIT
#   clients.  See [#727](https://github.com/sensu/sensu-puppet/issues/727) for
#   more information.  The default is undefined, which does not manage
#   `/etc/sensu/conf.d/spawn.json`
#   Default: undef
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
#   Boolean. Manage the sensu plugins directory. Must be false if you use
#   sensu::plugin with type 'directory'.
#   Default: true
#   Valid values: true, false
#
# [*manage_handlers_dir*]
#   Boolean. Manage the sensu handlers directory
#   Default: true
#   Valid values: true, false
#
# [*manage_mutators_dir*]
#   Boolean. Manage the sensu mutators directory
#   Default: true
#   Valid values: true, false
#
# [*rabbitmq_port*]
#   Integer.  Rabbitmq port to be used by sensu
#   Default: 5672
#
# [*rabbitmq_host*]
#   String.  Host running rabbitmq for sensu
#   Default: '127.0.0.1'
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
#   Default: '/sensu'
#
# [*rabbitmq_ssl*]
#   Boolean.  Use SSL transport to connect to RabbitMQ.  If rabbitmq_ssl_private_key and/or
#     rabbitmq_ssl_cert_chain are set, then this is enabled automatically.  Set rabbitmq_ssl => true
#     without specifying a private key or cert chain to use SSL transport, but not cert auth.
#   Default: false
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
# [*rabbitmq_prefetch*]
#   Integer.  The integer value for the RabbitMQ prefetch attribute
#   Default: 1
#
# [*rabbitmq_cluster*]
#   Array of hashes. Rabbitmq Cluster configuration and connection information for one or more Cluster
#   Default: Not configured
#
# [*rabbitmq_heartbeat*]
#   Integer.  The integer value for the RabbitMQ heartbeat attribute
#   Default: 30
#
# [*redis_host*]
#   String.  Hostname of redis to be used by sensu
#   Default: 127.0.0.1
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
#   Boolean. Reconnect to Redis in the event of a Redis error, e.g. READONLY
#     (not to be confused with a connection failure).
#   Default: true
#   Valid values: true, false
#
# [*redis_db*]
#   Integer.  The Redis instance DB to use/select
#   Default: 0
#
# [*redis_sentinels*]
#   Array. Redis Sentinel configuration and connection information for one or more Sentinels
#   Default: Not configured
#
# [*redis_master*]
#   String. Redis master name in the sentinel configuration
#   Default: undef. In the end whatever sensu defaults to, which is "mymaster" currently.
#
# [*redis_auto_reconnect*]
#   Boolean.  Reconnect to Redis in the event of a connection failure
#   Default: true
#
# [*transport_type*]
#   String. Transport type to be used by Sensu
#   Default: rabbitmq
#   Valid values: rabbitmq, redis
#
# [*transport_reconnect_on_error*]
#   Boolean. If the transport connection is closed, attempt to reconnect automatically when possible.
#   Default: true
#   Valid values: true, false
#
# [*api_bind*]
#   String.  IP to bind api service
#   Default: 0.0.0.0
#
# [*api_host*]
#   String.  Hostname of the sensu api service
#   Default: 127.0.0.1
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
# [*api_ssl_port*]
#   Integer. Port of the HTTPS (SSL) sensu api service. Enterprise only
#   feature.
#   Default: undef
#
# [*api_ssl_keystore_file*]
#   String. The file path for the SSL certificate keystore. Enterprise only
#   feature.
#   Default: undef
#
# [*api_ssl_keystore_password*]
#   String. The SSL certificate keystore password. Enterprise only feature.
#   Default: undef
#
# [*subscriptions*]
#   Array of strings.  Default subscriptions used by the client
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
#   String, Array of strings, Hash.  Plugins to install on the node
#     Strings and Arrays of strings will set 'install_path' => '/etc/sensu/plugins' as default.
#   Default: []
#   Example string: 'puppet:///data/sensu/plugins/plugin1.rb'
#   Example array: [ 'puppet:///data/sensu/plugins/plugin1.rb', 'puppet:///data/sensu/plugins/plugin2.rb' ]
#   Example hash: { 'puppet:///data/sensu/plugins/plugin1.rb' => { 'pkg_version' => '2.4.2' }, 'puppet:///data/sensu/plugins/plugin1.rb' => { 'pkg_provider' => 'sensu-gem' }
#
# [*plugins_defaults*]
#   Hash. Defaults for Plugins to install on the node. Will be added when plugins is set to a hash.
#   Default: {}
#   Example value: { 'install_path' => '/other/path' }
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
#   Boolean.  If the embedded ruby should be used, e.g. to install the
#   sensu-plugin gem.  This value is overridden by a defined
#   sensu_plugin_provider.  Note, the embedded ruby should always be used to
#   provide full compatibility.  Using other ruby runtimes, e.g. the system
#   ruby, is not recommended.
#   Default: true
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
#
# [*log_dir*]
#   String.  Sensu log directory to be used
#   Default: '/var/log/sensu'
#   Valid values: Any valid log directory path, accessible by the sensu user
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
# [*path*]
#   String. Used to set PATH in /etc/default/sensu
#   Default: '$PATH'
#
# [*redact*]
#   Array of strings. Use to redact passwords from checks on the client side
#   Default: undef
#
# [*deregister_on_stop*]
#   Boolean. Whether the sensu client should deregister from the API on service stop
#   Default: false
#
# [*deregister_handler*]
#   String. The handler to use when deregistering a client on stop.
#   Default: undef
#
# [*handlers*]
#   Hash of handlers for use with create_resources(sensu::handler).
#   Example value: { 'email' => { 'type' => 'pipe', 'command' => 'mail' } }
#   Default: {}
#
# [*handler_defaults*]
#   Handler defaults when not provided explicitly in $handlers.
#   Example value: { 'filters' => ['production'] }
#   Default: {}
#
# [*checks*]
#   Hash of checks for use with create_resources(sensu::check).
#   Example value: { 'check-cpu' => { 'command' => 'check-cpu.rb' } }
#   Default: {}
#
# [*check_defaults*]
#   Check defaults when not provided explicitly in $checks.
#   Example value: { 'occurrences' => 3 }
#   Default: {}
#
# [*filters*]
#   Hash of filters for use with create_resources(sensu::filter).
#   Example value: { 'occurrence' => { 'attributes' => { 'occurrences' => '1' } } }
#   Default: {}
#
# [*filter_defaults*]
#   Filter defaults when not provided explicitly in $filters.
#   Example value: { 'negate' => true }
#   Default: {}
#
# [*package_checksum*]
#   String. Used to set package_checksum for windows installs
#   Default: undef
#
# [*windows_logrotate*]
#   Boolean. Whether or not to use logrotate on Windows OS family.
#   Default: false
#
# [*windows_log_size*]
#   Integer. The integer value for the size of log files on Windows OS family. sizeThreshold in sensu-client.xml.
#   Default: '10240'
#
# [*windows_log_number*]
#   Integer. The integer value for the number of log files to keep on Windows OS family. keepFiles in sensu-client.xml.
#   Default: '10'
#
# [*windows_pkg_url*]
#   String.  If specified, override the behavior of computing the package source
#   URL from windows_repo_prefix and os major release fact.  This parameter is
#   intended to allow the end user to override the source URL used to install
#   the Windows package.  For example:
#   `"https://repositories.sensuapp.org/msi/2012r2/sensu-0.29.0-11-x64.msi"`
#   Default: undef
#
# [*windows_package_provider*]
#   String.  When something other than `undef`, use the specified package
#   provider to install Windows packages.  The default behavior of `undef`
#   defers to the default package provider in Puppet which is expected to be the
#   msi provider.  Valid values are `undef` or `'chocolatey'`.
#   Default: undef
#
# [*windows_choco_repo*]
#   String.  The URL of the Chocolatey repository, used with the chocolatey
#   windows package provider.
#   Default: undef
#
# [*windows_package_name*]
#   String.  The package name used to identify the package filename.  Defaults
#   to `'sensu'` which matches the MSI filename published at
#   `https://repositories.sensuapp.org/msi`.  Note, this is distinct from the
#   windows_package_title, which is used to identify the package name as
#   displayed in Add/Remove programs in Windows.
#   Default: 'sensu'
#
# [*windows_package_title*]
#   String.  The package name used to identify the package as listed in
#   Add/Remove programs.  Note this is distinct from the package filename
#   identifier specified with windows_package_name.
#   Default: 'Sensu'

class sensu (
  Pattern[/^absent$/, /^installed$/, /^latest$/, /^present$/, /^[\d\.\-el]+$/] $version = 'installed',
  String             $sensu_plugin_name = 'sensu-plugin',
  Optional[String]   $sensu_plugin_provider = $::osfamily ? {
    'windows' => 'gem',
    default   => undef,
  },
  Pattern[/^absent$/, /^installed$/, /^latest$/, /^present$/, /^\d[\d\.\-\w]+$/] $sensu_plugin_version = 'installed',
  Boolean            $install_repo = true,
  Boolean            $enterprise = false,
  Pattern[/^absent$/,/^installed$/,/^latest$/,/^present$/,/^[\d\.\-]+$/] $enterprise_version = 'latest',
  Optional[String]   $enterprise_user = undef,
  Optional[String]   $enterprise_pass = undef,
  Boolean            $enterprise_dashboard = false,
  String             $enterprise_dashboard_version = 'latest',
  Boolean            $manage_repo = true,
  Enum['main','unstable'] $repo = 'main',
  Optional[String]   $repo_source = undef,
  String             $repo_key_id = 'EE15CFF6AB6E4E290FDAB681A20F259AEB9C94BB',
  String             $repo_key_source = 'https://sensu.global.ssl.fastly.net/apt/pubkey.gpg',
  Optional[String]   $repo_release = undef,
  Variant[Undef,Integer,Pattern[/^(\d+)$/]] $spawn_limit = undef,
  String             $enterprise_repo_key_id = '910442FF8781AFD0995D14B311AB27E8C3FE3269',
  Boolean            $client = true,
  Boolean            $server = false,
  Boolean            $api = false,
  Boolean            $manage_services = true,
  Boolean            $manage_user = true,
  Boolean            $manage_plugins_dir = true,
  Boolean            $manage_handlers_dir = true,
  Boolean            $manage_mutators_dir = true,
  Variant[Undef,Integer,Pattern[/^(\d+)$/]] $rabbitmq_port = undef,
  Optional[String]   $rabbitmq_host = undef,
  Optional[String]   $rabbitmq_user = undef,
  Optional[String]   $rabbitmq_password = undef,
  Optional[String]   $rabbitmq_vhost = undef,
  Optional[Boolean]  $rabbitmq_ssl = undef,
  Optional[String]   $rabbitmq_ssl_private_key = undef,
  Optional[String]   $rabbitmq_ssl_cert_chain = undef,
  Variant[Undef,Integer,Pattern[/^(\d+)$/]] $rabbitmq_prefetch = undef,
  Variant[Undef,Hash,Array]                  $rabbitmq_cluster = undef,
  Variant[Undef,Integer,Pattern[/^(\d+)$/]] $rabbitmq_heartbeat = undef,
  Optional[String]   $redis_host = '127.0.0.1',
  Variant[Undef,Integer,Pattern[/^(\d+)$/]] $redis_port = 6379,
  Optional[String]   $redis_password = undef,
  Boolean            $redis_reconnect_on_error = true,
  Integer            $redis_db = 0,
  Boolean            $redis_auto_reconnect = true,
  Optional[Array]    $redis_sentinels = undef,
  Optional[String]   $redis_master = undef,
  Enum['rabbitmq','redis'] $transport_type = 'rabbitmq',
  Boolean            $transport_reconnect_on_error = true,
  String             $api_bind = '0.0.0.0',
  String             $api_host = '127.0.0.1',
  Integer            $api_port = 4567,
  Optional[String]   $api_user = undef,
  Optional[String]   $api_password = undef,
  Variant[Undef,Integer,Pattern[/^(\d+)$/]] $api_ssl_port = undef,
  Optional[String]   $api_ssl_keystore_file = undef,
  Optional[String]   $api_ssl_keystore_password = undef,
  Variant[String,Array] $subscriptions = [],
  String             $client_bind = '127.0.0.1',
  Integer            $client_port = 3030,
  String             $client_address =  $::ipaddress,
  String             $client_name =  $::fqdn,
  Hash               $client_custom = {},
  Hash               $client_keepalive = {},
  Boolean            $safe_mode = false,
  Variant[String,Array,Hash] $plugins = [],
  Hash               $plugins_defaults = {},
  Optional[String]   $plugins_dir = undef,
  Variant[Boolean,Hash] $purge = false,
  Boolean            $purge_config = false,
  Boolean            $purge_plugins_dir = false,
  Boolean            $use_embedded_ruby = true,
  Optional[String]   $rubyopt = undef,
  Optional[String]   $gem_path = undef,
  Enum['debug','info','warn','error','fatal'] $log_level = 'info',
  Stdlib::Absolutepath $log_dir = '/var/log/sensu',
  Boolean            $dashboard = false,
  Variant[Integer,Pattern[/^(\d+)$/]] $init_stop_max_wait = 10,
  Optional[Any]      $gem_install_options = undef,
  Boolean            $hasrestart = true,
  Optional[String]   $enterprise_dashboard_base_path = undef,
  Optional[String]   $enterprise_dashboard_host = undef,
  Variant[Undef,Integer,Pattern[/^(\d+)$/]] $enterprise_dashboard_port = undef,
  Optional[Any]      $enterprise_dashboard_refresh = undef,
  Optional[String]   $enterprise_dashboard_user = undef,
  Optional[String]   $enterprise_dashboard_pass = undef,
  Optional[Any]      $enterprise_dashboard_ssl = undef,
  Optional[Any]      $enterprise_dashboard_audit = undef,
  Optional[Any]      $enterprise_dashboard_github = undef,
  Optional[Any]      $enterprise_dashboard_gitlab = undef,
  Optional[Any]      $enterprise_dashboard_ldap = undef,
  String             $path = ' $PATH',
  Optional[Array]    $redact = undef,
  Boolean            $deregister_on_stop = false,
  Optional[String]   $deregister_handler = undef,
  Optional[String]   $package_checksum = undef,
  Optional[String]   $windows_pkg_url = undef,
  Optional[String]   $windows_repo_prefix = 'https://repositories.sensuapp.org/msi',
  Boolean            $windows_logrotate = false,
  Variant[Integer,Pattern[/^(\d+)$/]] $windows_log_number = 10,
  Variant[Integer,Pattern[/^(\d+)$/]] $windows_log_size = 10240,
  Optional[String]   $windows_package_provider = undef,
  Optional[String]   $windows_choco_repo = undef,
  String             $windows_package_name = 'Sensu',
  String             $windows_package_title = 'sensu',

  ### START Hiera Lookups###
  Hash               $extensions = {},
  Hash               $handlers = {},
  Hash               $handler_defaults = {},
  Hash               $checks = {},
  Hash               $check_defaults = {},
  Hash               $filters = {},
  Hash               $filter_defaults = {},
  Hash               $mutators = {},
  ### END Hiera Lookups ###

) {

  if $dashboard { fail('Sensu-dashboard is deprecated, use a dashboard module. See https://github.com/sensu/sensu-puppet#dashboards')}
  if $purge_config { fail('purge_config is deprecated, set the purge parameter to a hash containing `config => true` instead') }
  if $purge_plugins_dir { fail('purge_plugins_dir is deprecated, set the purge parameter to a hash containing `plugins => true` instead') }

  # sensu-enterprise supersedes sensu-server and sensu-api
  if ( $enterprise and $api ) or ( $enterprise and $server ) {
    fail('Sensu Enterprise: sensu-enterprise replaces sensu-server and sensu-api')
  }
  # validate enterprise repo credentials
  if $manage_repo {
    if ( $enterprise or $enterprise_dashboard ) and $install_repo {
      if $enterprise_user == undef or $enterprise_pass == undef {
        fail('The Sensu Enterprise repos require both enterprise_user and enterprise_pass to be set')
      }
    }
  }

  # Put here to avoid computing the conditionals for every check
  if $client {
    $client_service_class = Class['sensu::client::service']
  } else {
    $client_service_class = undef
  }

  if $server {
    $server_service_class = Class['sensu::server::service']
  } else {
    $server_service_class = undef
  }

  if $api {
    $api_service_class = Class['sensu::api::service']
  } else {
    $api_service_class = undef
  }

  $check_notify = delete_undef_values([ $client_service_class, $server_service_class, $api_service_class ])

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
  create_resources('::sensu::handler', $handlers, $handler_defaults)
  create_resources('::sensu::check', $checks, $check_defaults)
  create_resources('::sensu::filter', $filters, $filter_defaults)
  create_resources('::sensu::mutator', $mutators)

  case $::osfamily {
    'Debian','RedHat': {
      $etc_dir = '/etc/sensu'
      $conf_dir = "${etc_dir}/conf.d"
      $user = 'sensu'
      $group = 'sensu'
      $home_dir = '/opt/sensu'
      $shell = '/bin/false'
      $dir_mode = '0555'
      $file_mode = '0440'
    }

    'windows': {
      $etc_dir = 'C:/opt/sensu'
      $conf_dir = "${etc_dir}/conf.d"
      $user = 'NT Authority\SYSTEM'
      $group = 'Administrators'
      $home_dir = $etc_dir
      $shell = undef
      $dir_mode = undef
      $file_mode = undef
    }

    default: {}
  }

  # Include everything and let each module determine its state.  This allows
  # transitioning to purged config and stopping/disabling services
  anchor { 'sensu::begin': }
  -> class { '::sensu::package': }
  -> class { '::sensu::enterprise::package': }
  -> class { '::sensu::transport': }
  -> class { '::sensu::rabbitmq::config': }
  -> class { '::sensu::api::config': }
  -> class { '::sensu::redis::config': }
  -> class { '::sensu::client::config': }
  -> class { '::sensu::client::service':
    hasrestart => $hasrestart,
  }
  -> class { '::sensu::api::service':
    hasrestart => $hasrestart,
  }
  -> class { '::sensu::server::service':
    hasrestart => $hasrestart,
  }
  -> class { '::sensu::enterprise::service':
    hasrestart => $hasrestart,
  }
  -> class { '::sensu::enterprise::dashboard':
    hasrestart => $hasrestart,
  }
  -> anchor {'sensu::end': }

  if $plugins_dir {
    sensu::plugin { $plugins_dir: type => 'directory' }
  } else {
    case $plugins {
      String,Array: { sensu::plugin { $plugins: install_path => '/etc/sensu/plugins' } }
      Hash:         { create_resources('::sensu::plugin', $plugins, $plugins_defaults ) }
      default:      { fail('Invalid data type for $plugins, must be a string, an array, or a hash.') }
    }
  }
}
