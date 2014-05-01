require 'rubygems' if RUBY_VERSION < '1.9.0' && Puppet.version < '3'
require 'json' if Puppet.features.json?

begin
  require 'puppet_x/sensu/to_type'
rescue LoadError => e
  libdir = Pathname.new(__FILE__).parent.parent.parent.parent
  require File.join(libdir, 'puppet_x/sensu/to_type')
end

Puppet::Type.type(:sensu_client_config).provide(:json) do
  confine :feature => :json
  include Puppet_X::Sensu::Totype

  def initialize(*args)
    super

    begin
      @conf = JSON.parse(File.read(config_file))
    rescue
      @conf = {}
    end
  end

  def flush
    File.open(config_file, 'w') do |f|
      f.puts JSON.pretty_generate(@conf)
    end
  end

  def config_file
    "#{resource[:base_path]}/client.json"
  end

  def create
    @conf['client'] = {}
    self.client_name = resource[:client_name]
    self.address = resource[:address]
    self.subscriptions = resource[:subscriptions]
    self.safe_mode = resource[:safe_mode]
    self.custom = resource[:custom] unless resource[:custom].nil?
  end

  def destroy
    @conf = nil
  end

  def exists?
    @conf.has_key?('client')
  end

  def check_args
    ['name', 'address', 'subscriptions', 'safe_mode']
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

  def custom
    @conf['client'].reject { |k,v| check_args.include?(k) }
  end

  def custom=(value)
    @conf['client'].delete_if { |k,v| not check_args.include?(k) }
    @conf['client'].merge!(to_type(value))
  end

  def safe_mode
    case @conf['client']['safe_mode']
    when true
      :true
    when false
      :false
    else
      @conf['client']['safe_mode']
    end
  end

  def safe_mode=(value)
    case value
    when true, 'true', 'True', :true, 1
      @conf['client']['safe_mode'] = true
    else
      @conf['client']['safe_mode'] = false
    end
  end

end

