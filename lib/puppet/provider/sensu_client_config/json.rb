require 'rubygems' if RUBY_VERSION < '1.9.0' && Puppet.version < '3'
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
    self.safe_mode = resource[:safe_mode]
    # Optional arguments
    self.custom = resource[:custom] unless resource[:custom].nil?
  end

  def check_args
    ['name','address','subscriptions','safe_mode']
  end

  def custom
    tmp = {}
    @conf['client'].each do |k,v|
      if v.is_a?( Fixnum )
        tmp.merge!( k => v.to_s )
      else
        tmp.merge!( k => v )
      end
    end
    check_args.each do | del_arg |
      tmp.delete(del_arg)
    end
    tmp
  end

  def custom=(value)
    tmp = custom
    tmp.each_key do |k|
      @conf['client'].delete(k) unless check_args.include?(k)
    end
    value.each do | k, v |
      @conf['client'][ k ] =  to_type( v )
    end
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

