# @summary Base Sensu class
#
# This is the main Sensu class
#
# @param version Version of sensu to install.  Defaults to `installed` to support
#   Windows MSI packaging and to avoid surprising upgrades.
#
# @param sensu_etc_dir Absolute path to the sensu etc directory.
#   Default: '/etc/sensu' on Linux, 'C:/opt/sensu' on windows
#
# @param sensu_plugin_name Name of the sensu-plugin package. Refers to the
#   sensu-plugin rubygem, not the community sensu-plugins community scripts.
#
# @param sensu_plugin_provider
#   String.  Provider used to install the sensu-plugin package. Refers to the
#   sensu-plugin rubygem, not the sensu-plugins community scripts.  On windows,
#   defaults to `gem`, all other platforms defaults to `undef`
#
# @param sensu_plugin_version Version of the sensu-plugin gem to install.
#   Refers to the sensu-plugin rubygem, not the sensu-plugins community scripts
#
# @param install_repo Whether or not to install the sensu repo
#
# @param enterprise Whether or not to install and configure Sensu Enterprise
#
# @param enterprise_dashboard Whether or not to install sensu-enterprise-dashboard
#
# @param manage_repo Whether or not to manage apt/yum repositories
#
# @param repo Which sensu repo to install
#
# @param repo_source Location of the yum/apt repo.  Overrides the default location
#
# @param repo_key_id The apt GPG key id
#
# @param repo_key_source URL of the apt GPG key
#
# @param repo_release Release for the apt source. Only set this if you want to run
#   packages from another release, which is not supported by Sensu. Only works
#   with systems that use apt.
#
# @param spawn_limit Tune concurrency of the sensu-server pipe handler and the
#   sensu-client check execution.  This setting should not need to be tuned
#   except in specific situations, e.g. when there are a large number of JIT
#   clients.  See [#727](https://github.com/sensu/sensu-puppet/issues/727) for
#   more information.  The default is undefined, which does not manage
#   `/etc/sensu/conf.d/spawn.json`
#
# @param client Include the sensu client
#
# @param server Include the sensu server
#
# @param api Include the sensu api service
#
# @param manage_services Manage the sensu services with puppet
#
# @param manage_user Manage the sensu user with puppet
#
# @param manage_plugins_dir Manage the sensu plugins directory. Must be false if you use
#   sensu::plugin with type 'directory'.
#
# @param manage_handlers_dir Manage the sensu handlers directory
#
# @param manage_mutators_dir Manage the sensu mutators directory
#
# @param sensu_user Name of the user Sensu is running as. Default is calculated
#   according to the underlying OS
#
# @param sensu_group Name of the group Sensu is running as. Default is calculated
#   according to the underlying OS
#
# @param rabbitmq_port Rabbitmq port to be used by sensu
#
# @param rabbitmq_host Host running rabbitmq for sensu
#
# @param rabbitmq_user Username to connect to rabbitmq with for sensu
#
# @param rabbitmq_password Password to connect to rabbitmq with for sensu
#
# @param rabbitmq_vhost Rabbitmq vhost to be used by sensu
#
# @param rabbitmq_ssl Use SSL transport to connect to RabbitMQ.  If rabbitmq_ssl_private_key and/or
#   rabbitmq_ssl_cert_chain are set, then this is enabled automatically.  Set rabbitmq_ssl => true
#   without specifying a private key or cert chain to use SSL transport, but not cert auth.
#
# @param rabbitmq_ssl_private_key Private key to be used by sensu to connect to rabbitmq. If the value starts with
#   'puppet://' the file will be copied and used.  Also the key itself can be given as the
#   parameter value, or a variable, or using hiera.  Absolute paths will just be used as
#   a file reference, as you'd normally configure sensu.
#
# @param rabbitmq_ssl_cert_chain Private SSL cert chain to be used by sensu to connect to rabbitmq
#   If the value starts with 'puppet://' the file will be copied and used.   Also the key itself can
#   be given as the parameter value, or a variable, or using hiera. Absolute paths will just be used
#   as a file reference, as you'd normally configure sensu.
#
# @param rabbitmq_prefetch The integer value for the RabbitMQ prefetch attribute
#
# @param rabbitmq_cluster Array of hashes. Rabbitmq Cluster configuration
#   and connection information for one or more Cluster
#
# @param rabbitmq_heartbeat The integer value for the RabbitMQ heartbeat attribute
#
# @param redis_host Hostname of redis to be used by sensu
#
# @param redis_port Redis port to be used by sensu
#
# @param redis_password Password to be used to connect to Redis
#
# @param redis_reconnect_on_error Reconnect to Redis in the event of a Redis error, e.g. READONLY
#   (not to be confused with a connection failure).
#
# @param redis_db The Redis instance DB to use/select
#
# @param redis_sentinels Redis Sentinel configuration and connection information for one or more Sentinels
#
# @param redis_master Redis master name in the sentinel configuration
#   In the end whatever sensu defaults to, which is "mymaster" currently.
#
# @param redis_auto_reconnect Reconnect to Redis in the event of a connection failure
#
# @param transport_type Transport type to be used by Sensu
#
# @param transport_reconnect_on_error If the transport connection is closed, attempt to reconnect automatically when possible.
#
# @param api_bind IP to bind api service
#
# @param api_host Hostname of the sensu api service
#
# @param api_port Port of the sensu api service
#
# @param api_user Password of the sensu api service
#
# @param api_password Password of the sensu api service
#
# @param api_ssl_port Port of the HTTPS (SSL) sensu api service. Enterprise only
#   feature.
#
# @param api_ssl_keystore_file The file path for the SSL certificate keystore. Enterprise only
#   feature.
#
# @param api_ssl_keystore_password The SSL certificate keystore password. Enterprise only feature.
#
# @param subscriptions Default subscriptions used by the client
#
# @param client_address Address of the client to report with checks
#
# @param client_name Name of the client to report with checks
#
# @param client_custom Custom client variables.
#
# @param client_deregister Enable the [deregistration
#   event](https://sensuapp.org/docs/latest/reference/clients#deregistration-attributes)
#   if true.
#
# @param client_deregistration [Attributes](https://sensuapp.org/docs/latest/reference/clients#deregistration-attributes)
#   used to generate check result data for the de-registration event. Client
#   deregistration attributes are merged with some default check definition
#   attributes by the Sensu server during client deregistration, so any valid
#   check definition attributes – including custom check definition attributes
#   – may be used as deregistration attributes, with the following exceptions
#   (which are used to ensure the check result is valid): check name, output,
#   status, and issued timestamp. The following attributes are provided as
#   recommendations for controlling client deregistration behavior.
#
# @param client_registration [Attributes](https://sensuapp.org/docs/latest/reference/clients#registration-attributes)
#   used to generate check result data for the registration event. Client
#   registration attributes are merged with some default check definition
#   attributes by the Sensu server during client registration.
#
# @param client_keepalive Client keepalive configuration
#
# @param client_http_socket Client http_socket configuration. Must be an Hash of
#    parameters as described in:
#    https://sensuapp.org/docs/latest/reference/clients.html#http-socket-attributes
#
# @param client_servicenow Client servicenow configuration. Supported only
#   on Sensu Enterprise. It expects an Hash with a single key named
#   'configuration_item' containing an Hash of parameters, as described in:
#   https://sensuapp.org/docs/latest/reference/clients.html#servicenow-attributes
#
# @param client_ec2 Client ec2 configuration. Supported only on Sensu
#   Enterprise. It expects an Hash with valid paramters as described in:
#   https://sensuapp.org/docs/latest/reference/clients.html#ec2-attributes
#
# @param client_chef Client chef configuration. Supported only on Sensu
#   Enterprise. It expects an Hash with valid paramters as described in:
#   https://sensuapp.org/docs/latest/reference/clients.html#chef-attributes
#
# @param client_puppet Client puppet configuration. Supported only on Sensu
#   Enterprise. It expects an Hash with valid paramters as described in:
#   https://sensuapp.org/docs/latest/reference/clients.html#puppet-attributes
#
# @param safe_mode Force safe mode for checks
#
# @param plugins Plugins to install on the node
#   Strings and Arrays of strings will set 'install_path' => '/etc/sensu/plugins' as default.
#   Example string: 'puppet:///data/sensu/plugins/plugin1.rb'
#   Example array: [ 'puppet:///data/sensu/plugins/plugin1.rb', 'puppet:///data/sensu/plugins/plugin2.rb' ]
#   Example hash: { 'puppet:///data/sensu/plugins/plugin1.rb' => { 'pkg_version' => '2.4.2' }, 'puppet:///data/sensu/plugins/plugin1.rb' => { 'pkg_provider' => 'sensu-gem' }
#
# @param plugins_defaults Defaults for Plugins to install on the node. Will be added when plugins is set to a hash.
#   Example value: { 'install_path' => '/other/path' }
#
# @param plugins_dir Puppet url to plugins directory
#
# @param purge If unused plugins, configs, handlers, extensions and mutators should be removed from the system.
#   If set to true, all unused plugins, configs, handlers, extensions and mutators will be removed from the system.
#   If set to a Hash, only unused files of the specified type(s) will be removed from the system.
#   Valid values: true, false, Hash containing any of the keys 'plugins', 'config', 'handlers', 'extensions', 'mutators'
#   Example value: { config => true, plugins => true }
#
# @param use_embedded_ruby If the embedded ruby should be used, e.g. to install the
#   sensu-plugin gem.  This value is overridden by a defined
#   sensu_plugin_provider.  Note, the embedded ruby should always be used to
#   provide full compatibility.  Using other ruby runtimes, e.g. the system
#   ruby, is not recommended.
#
# @param rubyopt Ruby opts to be passed to the sensu services
#
# @param gem_path Paths to add to GEM_PATH if we need to look for different dirs.
#
# @param log_level Sensu log level to be used
#
# @param log_dir Sensu log directory to be used
#
# @param init_stop_max_wait Number of seconds to wait for the init stop script to run
#
# @param gem_install_options Optional configuration to use for the installation of the
#   sensu plugin gem with sensu_gem provider.
#   See: https://docs.puppetlabs.com/references/latest/type.html#package-attribute-install_options
#   Example value: [{ '-p' => 'http://user:pass@myproxy.company.org:8080' }]
#
# @param hasrestart Value of hasrestart attribute for sensu services.
#   If you use your own startup scripts for upstart and want puppet
#   to properly stop and start sensu services when those scripts change,
#   set it to false. See also http://upstart.ubuntu.com/faq.html#reload
#
# @param path Used to set PATH in /etc/default/sensu
#
# @param redact Use to redact passwords from checks on the client side
#
# @param deregister_on_stop Whether the sensu client should deregister from the API on service stop
#
# @param deregister_handler The handler to use when deregistering a client on stop.
#
# @param handlers Hash of handlers for use with create_resources(sensu::handler).
#   Example value: { 'email' => { 'type' => 'pipe', 'command' => 'mail' } }
#
# @param handler_defaults Handler defaults when not provided explicitly in $handlers.
#   Example value: { 'filters' => ['production'] }
#
# @param checks Hash of checks for use with create_resources(sensu::check).
#   Example value: { 'check-cpu' => { 'command' => 'check-cpu.rb' } }
#
# @param check_defaults Check defaults when not provided explicitly in $checks.
#   Example value: { 'occurrences' => 3 }
#
# @param filters Hash of filters for use with create_resources(sensu::filter).
#   Example value: { 'occurrence' => { 'attributes' => { 'occurrences' => '1' } } }
#
# @param filter_defaults Filter defaults when not provided explicitly in $filters.
#   Example value: { 'negate' => true }
#
# @param package_checksum Used to set package_checksum for windows installs
#
# @param windows_logrotate Whether or not to use logrotate on Windows OS family.
#
# @param windows_log_size The integer value for the size of log files on
#   Windows OS family. sizeThreshold in sensu-client.xml.
#
# @param windows_log_number The integer value for the number of log files to
#   keep on Windows OS family. keepFiles in sensu-client.xml.
#
# @param windows_pkg_url If specified, override the behavior of computing the
#   package source URL from windows_repo_prefix and os major release fact.
#   This parameter is intended to allow the end user to override the source URL
#   used to install the Windows package.  For example:
#   `"https://repositories.sensuapp.org/msi/2012r2/sensu-0.29.0-11-x64.msi"`
#
# @param windows_package_provider When something other than `undef`, use the
#   specified package provider to install Windows packages. The default
#   behavior of `undef` defers to the default package provider in Puppet which
#   is expected to be the msi provider.
#   Valid values are `undef` or `'chocolatey'`.
#
# @param windows_choco_repo The URL of the Chocolatey repository, used with
#   the chocolatey windows package provider.
#
# @param windows_package_name The package name used to identify the package
#   filename. Defaults to `'sensu'` which matches the MSI filename published at
#   `https://repositories.sensuapp.org/msi`.  Note, this is distinct from the
#   windows_package_title, which is used to identify the package name as
#   displayed in Add/Remove programs in Windows.
#
# @param windows_package_title The package name used to identify the package as
#   listed in Add/Remove programs.  Note this is distinct from the package
#   filename identifier specified with windows_package_name.
#
# @param confd_dir Additional directories to load configuration
#   snippets from.
#
# @param heap_size Value of the HEAP_SIZE environment variable.
#   Note: This has effect only on Sensu Enterprise.
#
# @param max_open_files Value of the MAX_OPEN_FILES environment variable.
#   Note: This has effect only on Sensu Enterprise.
#
class sensu (
  Pattern[/^absent$/, /^installed$/, /^latest$/, /^present$/, /^[\d\.\-el]+$/] $version = 'installed',
  String             $sensu_plugin_name = 'sensu-plugin',
  Optional[String]   $sensu_plugin_provider = $::osfamily ? {
    'windows' => 'gem',
    default   => undef,
  },
  Stdlib::Absolutepath $sensu_etc_dir = $::osfamily ? {
    'windows' => 'C:/opt/sensu',
    default   => '/etc/sensu',
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
  Optional[String]   $sensu_user = undef,
  Optional[String]   $sensu_group = undef,
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
  Variant[Undef,Boolean] $client_deregister = undef,
  Variant[Undef,Hash] $client_deregistration = undef,
  Variant[Undef,Hash] $client_registration = undef,
  Hash               $client_keepalive = {},
  Hash               $client_http_socket = {},
  Hash               $client_servicenow = {},
  Hash               $client_ec2 = {},
  Hash               $client_chef = {},
  Hash               $client_puppet = {},
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
  Variant[Stdlib::Absolutepath,Pattern[/^\$PATH$/]] $path = '$PATH',
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
  Optional[Variant[Stdlib::Absolutepath,Array[Stdlib::Absolutepath]]] $confd_dir = undef,
  Variant[Integer,Pattern[/^(\d+)/],Undef] $heap_size = undef,
  Variant[Integer,Pattern[/^(\d+)$/],Undef] $max_open_files = undef,
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
  if $client and $manage_services {
    $client_service = Service['sensu-client']
  } else {
    $client_service = undef
  }

  if $enterprise and $manage_services {
    $enterprise_service = Service['sensu-enterprise']
  } else {
    $enterprise_service = undef
  }

  if $server {
    $server_service_class = Class['sensu::server::service']
  } else {
    $server_service_class = undef
  }

  if $api and $manage_services and $::osfamily != 'windows' {
    $api_service = Service['sensu-api']
  } else {
    $api_service = undef
  }

  $check_notify = delete_undef_values([ $client_service, $server_service_class, $api_service, $enterprise_service ])

  # Because you can't reassign a variable in puppet and we need to set to
  # false if you specify a directory, we have to use another variable.
  if $plugins_dir {
    $_manage_plugins_dir = false
  } else {
    $_manage_plugins_dir = $manage_plugins_dir
  }

  if $purge =~ Boolean {
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

  # (#463) This well-known anchor serves as a reference point so all checks are
  # managed after all plugins.  It must always exist in the catalog.
  anchor { 'plugins_before_checks': }

  $extensions.each |$k,$v| {
    ::sensu::extension { $k:
      * => $v,
    }
  }
  $handlers.each |$k,$v| {
    ::sensu::handler { $k:
      * => $handler_defaults + $v,
    }
  }
  $checks.each |$k,$v| {
    ::sensu::check { $k:
      * => $check_defaults + $v,
    }
  }
  $filters.each |$k,$v| {
    ::sensu::filter { $k:
      * => $filter_defaults + $v,
    }
  }
  $mutators.each |$k,$v| {
    ::sensu::mutator { $k:
      * => $v,
    }
  }

  case $::osfamily {
    'Debian','RedHat': {
      $etc_dir = $sensu_etc_dir
      $conf_dir = "${etc_dir}/conf.d"
      $user = $sensu_user  ? {
        undef   => 'sensu',
        default => $sensu_user,
      }
      $group = $sensu_group ? {
        undef   => 'sensu',
        default => $sensu_group,
      }
      $home_dir = '/opt/sensu'
      $shell = '/bin/false'
      $dir_mode = '0555'
      $file_mode = '0440'
    }

    'windows': {
      $etc_dir = $sensu_etc_dir
      $conf_dir = "${etc_dir}/conf.d"
      $user = $sensu_user  ? {
        undef   => 'NT Authority\SYSTEM',
        default => $sensu_user,
      }
      $group = $sensu_group ? {
        undef   => 'Administrators',
        default => $sensu_group,
      }
      $home_dir = $etc_dir
      $shell = undef
      $dir_mode = undef
      $file_mode = undef
    }

    default: {}
  }

  # Include everything and let each module determine its state.  This allows
  # transitioning to purged config and stopping/disabling services
  contain ::sensu::package
  contain ::sensu::enterprise
  contain ::sensu::transport
  contain ::sensu::rabbitmq::config
  contain ::sensu::api
  contain ::sensu::redis::config
  contain ::sensu::client
  contain ::sensu::server::service
  contain ::sensu::enterprise::dashboard

  Class['::sensu::package']
  -> Class['::sensu::transport']
  -> Class['::sensu::rabbitmq::config']
  -> Sensu_api_config[$::fqdn]
  -> Class['::sensu::redis::config']
  -> Sensu_client_config[$::fqdn]
  -> Class['::sensu::server::service']
  -> Class['::sensu::enterprise::dashboard']

  if $plugins_dir {
    sensu::plugin { $plugins_dir: type => 'directory' }
  } else {
    case $plugins {
      String,Array: { sensu::plugin { $plugins: } }
      Hash:         { create_resources('::sensu::plugin', $plugins, $plugins_defaults ) }
      default:      { fail('Invalid data type for $plugins, must be a string, an array, or a hash.') }
    }
  }
}
