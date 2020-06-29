require File.expand_path(File.join(File.dirname(__FILE__), '..', 'sensuctl'))

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

  def url
    sensuctl_config['api-url']
  end

  def url=(value)
    @property_flush[:url] = value
  end

  def trusted_ca_file
    value = sensuctl_config['trusted-ca-file']
    if value == ''
      value = 'absent'
    end
    value
  end

  def trusted_ca_file=(value)
    @property_flush[:trusted_ca_file] = value
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
    cmd << resource[:password]
    sensuctl(cmd)
  end

  def create
    begin
      output = configure_cmd()
      sensuctl(['config','set-format',resource[:config_format]]) if resource[:config_format]
      sensuctl(['config','set-namespace',resource[:config_namespace]]) if resource[:config_namespace]
    rescue Puppet::ExecutionFailure => e
      File.delete(config_path) if File.exist?(config_path)
      raise Puppet::Error, "sensuctl configure failed\nOutput: #{output}\nError message: #{e.message}"
    end
  end

  def flush
    if !@property_flush.empty?
      begin
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

