require File.expand_path(File.join(File.dirname(__FILE__), '..', 'sensuctl'))
require File.expand_path(File.join(File.dirname(__FILE__), '..', 'sensu_api'))

Puppet::Type.type(:sensu_configure).provide(:sensuctl, :parent => Puppet::Provider::Sensuctl) do
  desc "Provider sensu_configure using sensuctl"

  def exists?
    File.file?(config_path)
  end

  def initialize(value = {})
    super(value)
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
      output = configure_cmd()
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
        configure_cmd()
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

