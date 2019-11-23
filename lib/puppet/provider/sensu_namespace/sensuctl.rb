require File.expand_path(File.join(File.dirname(__FILE__), '..', 'sensuctl'))

Puppet::Type.type(:sensu_namespace).provide(:sensuctl, :parent => Puppet::Provider::Sensuctl) do
  desc "Provider sensu_namespace using sensuctl"

  mk_resource_methods

  defaultfor :kernel => ['Linux','windows']

  def self.instances
    namespaces = []

    data = sensuctl_list('namespace', false)

    data.each do |d|
      namespace = {}
      namespace[:ensure] = :present
      namespace[:name] = d['name']
      namespaces << new(namespace)
    end
    namespaces
  end

  def self.prefetch(resources)
    namespaces = instances
    resources.keys.each do |name|
      if provider = namespaces.find { |c| c.name == name }
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
    spec[:name] = resource[:name]
    type_properties.each do |property|
      value = resource[property]
      next if value.nil?
      next if value == :absent || value == [:absent]
      if [:true, :false].include?(value)
        spec[property] = convert_boolean_property_value(value)
      else
        spec[property] = value
      end
    end
    begin
      sensuctl_create('Namespace', {}, spec)
    rescue Exception => e
      raise Puppet::Error, "sensuctl create #{resource[:name]} failed\nError message: #{e.message}"
    end
    @property_hash[:ensure] = :present
  end

  def flush
    if !@property_flush.empty?
      spec = {}
      spec[:name] = resource[:name]
      type_properties.each do |property|
        if @property_flush[property]
          value = @property_flush[property]
        else
          value = resource[property]
        end
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
        sensuctl_create('Namespace', {}, spec)
      rescue Exception => e
        raise Puppet::Error, "sensuctl create #{resource[:name]} failed\nError message: #{e.message}"
      end
    end
    @property_hash = resource.to_hash
  end

  def destroy
    begin
      sensuctl_delete('namespace', resource[:name])
    rescue Exception => e
      raise Puppet::Error, "sensuctl delete namespace #{resource[:name]} failed\nError message: #{e.message}"
    end
    @property_hash.clear
  end
end

