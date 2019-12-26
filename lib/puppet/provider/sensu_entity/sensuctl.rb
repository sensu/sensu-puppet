require File.expand_path(File.join(File.dirname(__FILE__), '..', 'sensuctl'))

Puppet::Type.type(:sensu_entity).provide(:sensuctl, :parent => Puppet::Provider::Sensuctl) do
  desc "Provider sensu_entity using sensuctl"

  mk_resource_methods

  defaultfor :kernel => ['Linux','windows']

  def self.instances
    entities = []

    data = sensuctl_list('entity')

    data.each do |d|
      entity = {}
      entity[:ensure] = :present
      entity[:resource_name] = d['metadata']['name']
      entity[:namespace] = d['metadata']['namespace']
      entity[:name] = "#{entity[:resource_name]} in #{entity[:namespace]}"
      entity[:labels] = d['metadata']['labels']
      entity[:annotations] = d['metadata']['annotations']
      d.each_pair do |key,value|
        next if key == 'metadata'
        if !!value == value
          value = value.to_s.to_sym
        end
        if type_properties.include?(key.to_sym)
          entity[key.to_sym] = value
        else
          next
        end
      end
      entities << new(entity)
    end
    entities
  end

  def self.prefetch(resources)
    entities = instances
    resources.keys.each do |name|
      if provider = entities.find { |e| e.resource_name == resources[name][:resource_name] && e.namespace == resources[name][:namespace] }
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
    metadata = {}
    metadata[:name] = resource[:resource_name]
    type_properties.each do |property|
      value = resource[property]
      next if value.nil?
      next if value == :absent || value == [:absent]
      next if [:system, :last_seen, :user].include?(property)
      if [:true, :false].include?(value)
        value = convert_boolean_property_value(value)
      end
      if property == :namespace
        metadata[:namespace] = value
      elsif property == :labels
        metadata[:labels] = value
      elsif property == :annotations
        metadata[:annotations] = value
      else
        spec[property] = value
      end
    end
    begin
      sensuctl_create('Entity', metadata, spec)
    rescue Exception => e
      raise Puppet::Error, "sensuctl create #{resource[:id]} failed\nError message: #{e.message}"
    end
    @property_hash[:ensure] = :present
  end

  def flush
    if !@property_flush.empty?
      spec = {}
      metadata = {}
      metadata = {}
      metadata[:name] = resource[:resource_name]
      type_properties.each do |property|
        if @property_flush[property]
          value = @property_flush[property]
        else
          value = resource[property]
        end
        if property == :entity_class
          if ! value
            value = @property_hash[property]
          end
        end
        next if value.nil?
        next if [:system, :last_seen, :user].include?(property)
        if [:true, :false].include?(value)
          value = convert_boolean_property_value(value)
        elsif value == :absent
          value = nil
        end
        if property == :namespace
          metadata[:namespace] = value
        elsif property == :labels
          metadata[:labels] = value
        elsif property == :annotations
          metadata[:annotations] = value
        else
          spec[property] = value
        end
      end
      begin
        sensuctl_create('Entity', metadata, spec)
      rescue Exception => e
        raise Puppet::Error, "sensuctl create #{resource[:name]} failed\nError message: #{e.message}"
      end
    end
    @property_hash = resource.to_hash
  end

  def destroy
    begin
      sensuctl_delete('entity', resource[:resource_name], resource[:namespace])
    rescue Exception => e
      raise Puppet::Error, "sensuctl delete entity #{resource[:name]} failed\nError message: #{e.message}"
    end
    @property_hash.clear
  end
end

