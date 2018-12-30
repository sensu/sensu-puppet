require File.expand_path(File.join(File.dirname(__FILE__), '..', 'sensuctl'))

Puppet::Type.type(:sensu_role).provide(:sensuctl, :parent => Puppet::Provider::Sensuctl) do
  desc "Provider sensu_role using sensuctl"

  mk_resource_methods

  def self.instances
    roles = []

    output = sensuctl_list('role')
    Puppet.debug("sensu roles: #{output}")
    begin
      data = JSON.parse(output)
    rescue JSON::ParserError => e
      Puppet.debug('Unable to parse output from sensuctl role list')
      data = []
    end

    data.each do |d|
      role = {}
      role[:ensure] = :present
      role[:name] = d['metadata']['name']
      role[:namespace] = d['metadata']['namespace']
      d.each_pair do |key, value|
        next if key == 'metadata'
        if !!value == value
          value = value.to_s.to_sym
        end
        if type_properties.include?(key.to_sym)
          role[key.to_sym] = value
        end
      end
      roles << new(role)
    end
    roles
  end

  def self.prefetch(resources)
    roles = instances
    resources.keys.each do |name|
      if provider = roles.find { |c| c.name == name }
        resources[name].provider = provider
      end
    end
  end

  def exists?
    @property_hash[:ensure] == :present
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
    metadata = {}
    metadata[:name] = resource[:name]
    type_properties.each do |property|
      value = resource[property]
      next if value.nil?
      next if value == :absent || value == [:absent]
      if [:true, :false].include?(value)
        value = convert_boolean_property_value(value)
      else
        value = value
      end
      if property == :namespace
        metadata[:namespace] = value
      else
        spec[property] = value
      end
    end
    begin
      sensuctl_create('role', metadata, spec)
    rescue Exception => e
      raise Puppet::Error, "sensuctl create #{resource[:name]} failed\nError message: #{e.message}"
    end
    @property_hash[:ensure] = :present
  end

  def flush
    if !@property_flush.empty?
      spec = {}
      metadata = {}
      metadata[:name] = resource[:name]
      type_properties.each do |property|
        if @property_flush[property]
          value = @property_flush[property]
        else
          value = resource[property]
        end
        next if value.nil?
        if [:true, :false].include?(value)
          value = convert_boolean_property_value(value)
        elsif value == :absent
          value = nil
        end
        if property == :namespace
          metadata[:namespace] = value
        else
          spec[property] = value
        end
      end
      begin
        sensuctl_create('role', metadata, spec)
      rescue Exception => e
        raise Puppet::Error, "sensuctl create #{resource[:name]} failed\nError message: #{e.message}"
      end
    end
    @property_hash = resource.to_hash
  end

  def destroy
    begin
      sensuctl_delete('role', resource[:name])
    rescue Exception => e
      raise Puppet::Error, "sensuctl delete role #{resource[:name]} failed\nError message: #{e.message}"
    end
    @property_hash.clear
  end
end

