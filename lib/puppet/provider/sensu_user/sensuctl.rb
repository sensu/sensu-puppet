require File.expand_path(File.join(File.dirname(__FILE__), '..', 'sensuctl'))
require 'bcrypt' if Puppet.features.bcrypt?

Puppet::Type.type(:sensu_user).provide(:sensuctl, :parent => Puppet::Provider::Sensuctl) do
  desc "Provider sensu_user using sensuctl"

  confine feature: :bcrypt

  mk_resource_methods

  def self.instances
    users = []

    output = sensuctl_list('user')
    Puppet.debug("sensu users: #{output}")
    begin
      data = JSON.parse(output)
    rescue JSON::ParserError => e
      Puppet.debug('Unable to parse output from sensuctl user list')
      data = []
    end

    data.each do |d|
      user = {}
      user[:ensure] = :present
      user[:name] = d['username']
      d.each_pair do |key, value|
        next if key == 'name'
        if !!value == value
          value = value.to_s.to_sym
        end
        if type_properties.include?(key.to_sym)
          user[key.to_sym] = value
        end
      end
      users << new(user)
    end
    users
  end

  def self.prefetch(resources)
    users = instances
    resources.keys.each do |name|
      if provider = users.find { |c| c.name == name }
        resources[name].provider = provider
      end
    end
  end

  def exists?
    @property_hash[:ensure] == :present
  end

  def password_insync?(hash, password)
    BCrypt::Password.new(hash) == password
  end

  def initialize(value = {})
    super(value)
    @property_flush = {}
  end

  type_properties.each do |prop|
    define_method "#{prop}=".to_sym do |value|
      @property_flush[prop] = value
    end
  end

  def create
    spec = {}
    spec[:name] = resource[:name]
    spec[:password] = BCrypt::Password.create(resource[:password])
    type_properties.each do |property|
      value = resource[property]
      next if value.nil?
      next if property == :password
      next if value == :absent || value == [:absent]
      if [:true, :false].include?(value)
        spec[property] = convert_boolean_property_value(value)
      else
        spec[property] = value
      end
    end
    begin
      sensuctl_create('user', spec)
    rescue Exception => e
      raise Puppet::Error, "sensuctl create #{resource[:name]} failed\nError message: #{e.message}"
    end
    if resource[:configure] == :true
      sensuctl('configure', '-n', '--url', resource[:configure_url], '--username', resource[:name], '--password', resource[:password])
    end
    @property_hash[:ensure] = :present
  end

  def flush
    if !@property_flush.empty?
      spec = {}
      spec[:name] = resource[:name]
      spec[:password] = BCrypt::Password.create(@property_flush[:password]) if @property_flush[:password]
      type_properties.each do |property|
        if @property_flush[property]
          value = @property_flush[property]
        else
          value = resource[property]
        end
        next if property == :password
        next if value.nil?
        if [:true, :false].include?(value)
          spec[property] = convert_boolean_property_value(value)
        elsif value == :absent
          spec[property] = nil
        else
          spec[property] = value
        end
      end
      begin
        sensuctl_create('user', spec)
      rescue Exception => e
        raise Puppet::Error, "sensuctl create #{resource[:name]} failed\nError message: #{e.message}"
      end
      if resource[:configure] == :true && @property_flush[:password]
        sensuctl('configure', '-n', '--url', resource[:configure_url], '--username', resource[:name], '--password', @property_flush[:password])
      end
    end
    @property_hash = resource.to_hash
  end

  def destroy
    begin
      sensuctl_delete('user', resource[:name])
    rescue Exception => e
      raise Puppet::Error, "sensuctl delete user #{name} failed\nError message: #{e.message}"
    end
    @property_hash.clear
  end
end

