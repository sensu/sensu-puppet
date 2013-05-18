require 'rubygems' if RUBY_VERSION < '1.9.0' && Puppet.version < '3'
require 'json' if Puppet.features.json?

Puppet::Type.type(:sensu_check).provide(:json) do
  confine :feature => :json

  def initialize(*args)
    super

    @conf = nil
  end

  def conf
    begin
      @conf ||= JSON.parse(File.read("/etc/sensu/conf.d/checks/#{resource[:name]}.json"))
    rescue
      @conf ||= {}
    end
  end

  def flush
    File.open("/etc/sensu/conf.d/checks/#{resource[:name]}.json", 'w') do |f|
      f.puts JSON.pretty_generate(conf)
    end
  end

  def create
    conf['checks'] = {}
    conf['checks'][resource[:name]] = {}
    self.handlers = resource[:handlers]
    self.command = resource[:command]
    self.interval = resource[:interval]
    self.subscribers = resource[:subscribers]
    # Optional arguments
    self.type = resource[:type] unless resource[:type].nil?
    self.standalone = resource[:standalone] unless resource[:standalone].nil?
    self.high_flap_threshold = resource[:high_flap_threshold] unless resource[:high_flap_threshold].nil?
    self.low_flap_threshold = resource[:low_flap_threshold] unless resource[:low_flap_threshold].nil?
    self.custom = resource[:custom] unless resource[:custom].nil?
  end

  def check_args
    ['handlers','command','interval','subscribers','type','standalone','high_flap_threshold','low_flap_threshold']
  end

  def custom
    tmp = {}
    conf['checks'][resource[:name]].each do |k,v|
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
      conf['checks'][resource[:name]].delete(k) unless check_args.include?(k)
    end
    value.each do | k, v |
      conf['checks'][resource[:name]][ k ] =  to_type( v )
    end
  end

  def to_type(value)
    case value
    when true, 'true', 'True', :true
      true
    when false, 'false', 'False', :false
      false
    when /^([0-9])+$/
      value.to_i
    else
      value
    end
  end

  def destroy
    conf = nil
  end

  def exists?
    conf.has_key?('checks') and conf['checks'].has_key?(resource[:name])
  end

  def interval
    conf['checks'][resource[:name]]['interval'].to_s
  end

  def interval=(value)
    conf['checks'][resource[:name]]['interval'] = value.to_i
  end

  def handlers
    conf['checks'][resource[:name]]['handlers'] || []
  end

  def handlers=(value)
    conf['checks'][resource[:name]]['handlers'] = value
  end

  def command
    conf['checks'][resource[:name]]['command']
  end

  def command=(value)
    conf['checks'][resource[:name]]['command'] = value
  end

  def subscribers
    conf['checks'][resource[:name]]['subscribers'] || []
  end

  def subscribers=(value)
    conf['checks'][resource[:name]]['subscribers'] = value
  end

  def type
    conf['checks'][resource[:name]]['type']
  end

  def type=(value)
    conf['checks'][resource[:name]]['type'] = value
  end

  def low_flap_threshold
    conf['checks'][resource[:name]]['low_flap_threshold'].to_s
  end

  def low_flap_threshold=(value)
    conf['checks'][resource[:name]]['low_flap_threshold'] = value.to_i
  end

  def high_flap_threshold
    conf['checks'][resource[:name]]['high_flap_threshold'].to_s
  end

  def high_flap_threshold=(value)
    conf['checks'][resource[:name]]['high_flap_threshold'] = value.to_i
  end

  def standalone
    case conf['checks'][resource[:name]]['standalone']
    when true
      :true
    when false
      :false
    else
      conf['checks'][resource[:name]]['standalone']
    end
  end

  def standalone=(value)
    case value
    when true, 'true', 'True', :true, 1
      conf['checks'][resource[:name]]['standalone'] = true
    when false, 'false', 'False', :false, 0
      conf['checks'][resource[:name]]['standalone'] = false
    else
      conf['checks'][resource[:name]]['standalone'] = value
    end
  end
end
