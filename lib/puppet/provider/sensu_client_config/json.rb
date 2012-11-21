require 'rubygems' if RUBY_VERSION < '1.9.0' && Puppet.features.rubygems?
require 'json' if Puppet.features.json?

Puppet::Type.type(:sensu_client_config).provide(:json) do
  confine :feature => :json

  def initialize(*args)
    super

    begin
      @conf = JSON.parse(File.read('/etc/sensu/conf.d/client.json'))
    rescue
      @conf = {}
    end
  end

  def flush
    File.open('/etc/sensu/conf.d/client.json', 'w') do |f|
      f.puts JSON.pretty_generate(@conf)
    end
  end

  def create
    @conf['client'] = {}
    self.client_name = resource[:client_name]
    self.address = resource[:address]
    self.subscriptions = resource[:subscriptions]
  end

  def destroy
    @conf = nil
  end

  def exists?
    @conf.has_key?('client')
  end

  def client_name
    @conf['client']['name']
  end

  def client_name=(value)
    @conf['client']['name'] = value
  end

  def address
    @conf['client']['address']
  end

  def address=(value)
    @conf['client']['address'] = value
  end

  def subscriptions
    @conf['client']['subscriptions'] || []
  end

  def subscriptions=(value)
    @conf['client']['subscriptions'] = value
  end
end
