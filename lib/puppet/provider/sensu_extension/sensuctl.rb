require File.expand_path(File.join(File.dirname(__FILE__), '..', 'sensuctl'))

Puppet::Type.type(:sensu_extension).provide(:sensuctl, :parent => Puppet::Provider::Sensuctl) do
  desc "Provider sensu_extension using sensuctl"

  mk_resource_methods

  def self.instances
    extensions = []

    output = sensuctl_list('extension')
    Puppet.debug("sensu extensions: #{output}")
    begin
      data = JSON.parse(output)
    rescue JSON::ParserError => e
      Puppet.debug('Unable to parse output from sensuctl extension list')
      data = []
    end

    data.each do |d|
      extension = {}
      extension[:ensure] = :present
      extension[:name] = d['metadata']['name']
      extension[:namespace] = d['metadata']['namespace']
      d.each_pair do |key, value|
        next if key == 'metadata'
        if !!value == value
          value = value.to_s.to_sym
        end
        if type_properties.include?(key.to_sym)
          extension[key.to_sym] = value
        end
      end
      extensions << new(extension)
    end
    extensions
  end

  def self.prefetch(resources)
    extensions = instances
    resources.keys.each do |name|
      if provider = extensions.find { |e| e.name == name }
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
    spec[:metadata] = {}
    spec[:metadata][:name] = resource[:name]
    type_properties.each do |property|
      value = resource[property]
      next if value.nil?
      next if value == :absent || value == [:absent]
      if [:true, :false].include?(value)
        value = convert_boolean_property_value(value)
      end
      if property == :namespace
        spec[:metadata][:namespace] = value
      else
        spec[property] = value
      end
    end
    begin
      sensuctl_create('extension', spec)
    rescue Exception => e
      raise Puppet::Error, "sensuctl create #{resource[:name]} failed\nError message: #{e.message}"
    end
    @property_hash[:ensure] = :present
  end

  def flush
    if !@property_flush.empty?
      spec = {}
      spec[:metadata] = {}
      spec[:metadata][:name] = resource[:name]
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
          spec[:metadata][:namespace] = value
        else
          spec[property] = value
        end
      end
      begin
        sensuctl_create('extension', spec)
      rescue Exception => e
        raise Puppet::Error, "sensuctl create #{resource[:name]} failed\nError message: #{e.message}"
      end
    end
    @property_hash = resource.to_hash
  end

  def destroy
    begin
      sensuctl('extension', 'deregister', resource[:name])
    rescue Exception => e
      raise Puppet::Error, "sensuctl extension deregister #{resource[:name]} failed\nError message: #{e.message}"
    end
    @property_hash.clear
  end
end

