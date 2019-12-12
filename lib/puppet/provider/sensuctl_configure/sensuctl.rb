require File.expand_path(File.join(File.dirname(__FILE__), '..', 'sensuctl'))
require File.expand_path(File.join(File.dirname(__FILE__), '..', 'sensu_api'))

Puppet::Type.type(:sensuctl_configure).provide(:sensuctl, :parent => Puppet::Provider::Sensuctl) do
  desc "Provider sensuctl_configure using sensuctl"

  def exists?
    File.file?(config_path)
  end

  def initialize(value = {})
    super(value)
    @config = nil
    @property_flush = {}
  end

  def api
    @api ||= Puppet::Provider::SensuAPI.new()
  end

  def url
    config = load_config(config_path)
    config['api-url']
  end

  def url=(value)
    @property_flush[:url] = value
  end

  def trusted_ca_file
    config = load_config(config_path)
    value = config['trusted-ca-file']
    if value == ''
      value = 'absent'
    end
    value
  end

  def trusted_ca_file=(value)
    @property_flush[:trusted_ca_file] = value
  end

  # The default Sensu Go admin password
  def bootstrap_password
    'P@ssw0rd!'
  end

  def config
    return @config unless @config.nil?
    output = sensuctl(['config', 'view', '--format', 'json'])
    @config = JSON.parse(output)
    @config
  end

  def config_format
    config['format']
  end
  def config_format=(value)
    @property_flush[:config_format] = value
  end

  def config_namespace
    config['namespace']
  end
  def config_namespace=(value)
    @property_flush[:config_namespace] = value
  end

  def backend_init
    backend = which('sensu-backend')
    return if backend.nil?
    return if api.auth_test(resource[:url], resource[:username], resource[:password])
    return if api.auth_test(resource[:url], resource[:username], resource[:old_password])
    return if api.auth_test(resource[:url], resource[:username], bootstrap_password)
    custom_environment = {
      'SENSU_BACKEND_CLUSTER_ADMIN_USERNAME' => resource[:username],
      'SENSU_BACKEND_CLUSTER_ADMIN_PASSWORD' => resource[:password],
    }
    Puppet.notice("Sensuctl_configure[#{resource[:name]}]: Initializing sensu-backend")
    execute([backend, 'init'], :failonfail => false, :custom_environment => custom_environment)
  end

  def configure_cmd()
    trusted_ca_file = @property_flush[:trusted_ca_file] || resource[:trusted_ca_file]
    cmd = ['configure']
    if trusted_ca_file && trusted_ca_file != 'absent'
      cmd << '--trusted-ca-file'
      cmd << trusted_ca_file
    end
    cmd << '--non-interactive'
    cmd << '--url'
    cmd << resource[:url]
    cmd << '--username'
    cmd << resource[:username]
    cmd << '--password'
    if exists?
      if resource[:old_password] && api.auth_test(resource[:url], resource[:username], resource[:old_password])
        cmd << resource[:old_password]
      else
        cmd << resource[:password]
      end
    else
      # Test if default password works and use that password first
      # This supports bootstrapping sensuctl on fresh installs of sensu backend
      if api.auth_test(resource[:url], resource[:username], bootstrap_password)
        cmd << bootstrap_password
      else
        cmd << resource[:password]
      end
    end
    sensuctl(cmd)
  end

  def create
    begin
      backend_init
      output = configure_cmd()
      sensuctl(['config','set-format',resource[:config_format]]) if resource[:config_format]
      sensuctl(['config','set-namespace',resource[:config_namespace]]) if resource[:config_namespace]
    rescue Puppet::ExecutionFailure => e
      File.delete(config_path) if File.exist?(config_path)
      raise Puppet::Error, "sensuctl configure failed\nOutput: #{output}\nError message: #{e.message}"
    rescue Exception => e
      raise Puppet::Error, "sensuctl configure failed\nError message: #{e.message}"
    end
  end

  def flush
    if !@property_flush.empty?
      begin
        if @property_flush[:trusted_ca_file] == 'absent'
          Puppet.info("Clearing trusted-ca-file in #{config_path}")
          config = load_config
          config['trusted-ca-file'] = ''
          save_config(config)
        end
        backend_init
        configure_cmd()
        sensuctl(['config','set-format',@property_flush[:config_format]]) if @property_flush[:config_format]
        sensuctl(['config','set-namespace',@property_flush[:config_namespace]]) if @property_flush[:config_namespace]
      rescue Exception => e
        raise Puppet::Error, "sensuctl configure failed\nError message: #{e.message}"
      end
    end
  end

  def destroy
    Puppet.info("Deleting #{config_path}")
    File.delete(config_path)
  end
end

