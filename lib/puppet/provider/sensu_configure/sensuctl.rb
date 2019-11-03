require File.expand_path(File.join(File.dirname(__FILE__), '..', 'sensuctl'))

Puppet::Type.type(:sensu_configure).provide(:sensuctl, :parent => Puppet::Provider::Sensuctl) do
  desc "Provider sensu_configure using sensuctl"

  def exists?
    File.file?(config_path)
  end

  def initialize(value = {})
    super(value)
    @property_flush = {}
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

  def configure_cmd(bootstrap)
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
    if bootstrap
      cmd << resource[:bootstrap_password]
    else
      cmd << resource[:password]
    end
    sensuctl(cmd)
  end

  def create
    begin
      output = configure_cmd(resource[:bootstrap])
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
          Puppet.info("Deleting #{config_path} to clear trusted-ca-file")
          File.delete(config_path) if File.exist?(config_path)
        end
        configure_cmd(false)
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

