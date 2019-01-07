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

  def configure_cmd(bootstrap)
    cmd = ['configure']
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
      configure_cmd(true)
    rescue Puppet::ExecutionFailure => e
      File.delete(config_path)
      raise Puppet::Error, "sensuctl configure failed\nError message: #{e.message}"
    rescue Exception => e
      raise Puppet::Error, "sensuctl configure failed\nError message: #{e.message}"
    end
  end

  def flush
    if !@property_flush.empty?
      begin
        configure_cmd(false)
      rescue Exception => e
        raise Puppet::Error, "sensuctl configure failed\nError message: #{e.message}"
      end
    end
  end

  def destroy
    File.delete(config_path)
  end
end

