require File.expand_path(File.join(File.dirname(__FILE__), '..', 'sensuctl'))

Puppet::Type.type(:sensu_cluster_federation).provide(:sensuctl, :parent => Puppet::Provider::Sensuctl) do
  desc "Provider sensu_cluster_federation using sensuctl"

  mk_resource_methods

  defaultfor :kernel => ['Linux','windows']

  def self.instances
    clusters = []

    data = dump('federation/v1.Cluster')
    data.each do |d|
      cluster = {}
      cluster[:ensure] = :present
      cluster[:name] = d['metadata']['name']
      d['spec'].each_pair do |key,value|
        if !!value == value
          value = value.to_s.to_sym
        end
        if type_properties.include?(key.to_sym)
          cluster[key.to_sym] = value
        else
          next
        end
      end
      clusters << new(cluster)
    end
    clusters
  end

  def self.prefetch(resources)
    clusters = instances
    resources.keys.each do |name|
      if provider = clusters.find { |c| c.name == name }
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
      if [:true, :false].include?(value)
        value = convert_boolean_property_value(value)
      elsif value == :absent
        value = nil
      end
      spec[property] = value
    end
    begin
      sensuctl_create('Cluster', metadata, spec, 'federation/v1')
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
        spec[property] = value
      end
      begin
        sensuctl_create('Cluster', metadata, spec, 'federation/v1')
      rescue Exception => e
        raise Puppet::Error, "sensuctl create #{resource[:name]} failed\nError message: #{e.message}"
      end
    end
    @property_hash = resource.to_hash
  end

  def destroy
    spec = {}
    metadata = {}
    metadata[:name] = resource[:name]
    type_properties.each do |property|
      if @property_hash[property]
        value = @property_hash[property]
      else
        value = resource[property]
      end
      next if value.nil?
      if [:true, :false].include?(value)
        value = convert_boolean_property_value(value)
      elsif value == :absent
        value = nil
      end
      property = :resource if property == :resource_name
      spec[property] = value
    end
    begin
      sensuctl_delete('Cluster', resource[:name], nil, metadata, spec, 'federation/v1')
    rescue Exception => e
      raise Puppet::Error, "sensuctl delete #{resource[:name]} failed\nError message: #{e.message}"
    end
    @property_hash.clear
  end
end
