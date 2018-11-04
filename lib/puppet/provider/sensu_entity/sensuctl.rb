require File.expand_path(File.join(File.dirname(__FILE__), '..', 'sensuctl'))

Puppet::Type.type(:sensu_entity).provide(:sensuctl, :parent => Puppet::Provider::Sensuctl) do
  desc "Provider sensu_entity using sensuctl"

  mk_resource_methods

  def self.instances
    entities = []

    output = sensuctl_list('entity')
    Puppet.debug("sensu entities: #{output}")
    begin
      data = JSON.parse(output)
    rescue JSON::ParserError => e
      Puppet.debug('Unable to parse output from sensuctl entity list')
      data = []
    end

    data.each do |d|
      entity = {}
      entity[:ensure] = :present
      entity[:name] = d['id']
      entity[:id] = d['id']
      entity[:namespace] = d['metadata']['namespace']
      entity[:labels] = d['metadata']['labels']
      entity[:annotations] = d['metadata']['annotations']
      d.each_pair do |key,value|
        next if key == 'id'
        next if key == 'metadata'
        if !!value == value
          value = value.to_s.to_sym
        end
        if key == 'deregistration'
          entity[:deregistration_handler] = value['handler']
        elsif key == 'class'
          entity[:entity_class] = value
        elsif type_properties.include?(key.to_sym)
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
      if provider = entities.find { |e| e.name == name }
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
    spec[:id] = resource[:id]
    spec[:metadata] = {}
    type_properties.each do |property|
      value = resource[property]
      next if value.nil?
      next if value == :absent || value == [:absent]
      next if [:system, :last_seen, :user].include?(property)
      if [:true, :false].include?(value)
        value = convert_boolean_property_value(value)
      end
      if property == :entity_class
        spec[:class] = value
      elsif property == :deregistration_handler
        spec[:deregistration] = {handler: value}
      elsif property == :namespace
        spec[:metadata][:namespace] = value
      elsif property == :labels
        spec[:metadata][:labels] = value
      elsif property == :annotations
        spec[:metadata][:annotations] = value
      else
        spec[property] = value
      end
    end
    begin
      sensuctl_create('entity', spec)
    rescue Exception => e
      raise Puppet::Error, "sensuctl create #{resource[:id]} failed\nError message: #{e.message}"
    end
    @property_hash[:ensure] = :present
  end

  def flush
    if !@property_flush.empty?
      spec = {}
      spec[:id] = resource[:id]
      spec[:metadata] = {}
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
        if property == :entity_class
          spec[:class] = value
        elsif property == :deregistration_handler
          spec[:deregistration] = {handler: value}
        elsif property == :namespace
          spec[:metadata][:namespace] = value
        elsif property == :labels
          spec[:metadata][:labels] = value
        elsif property == :annotations
          spec[:metadata][:annotations] = value
        else
          spec[property] = value
        end
      end
      begin
        sensuctl_create('entity', spec)
      rescue Exception => e
        raise Puppet::Error, "sensuctl create #{resource[:name]} failed\nError message: #{e.message}"
      end
    end
    @property_hash = resource.to_hash
  end

  def destroy
    begin
      sensuctl_delete('entity', resource[:name])
    rescue Exception => e
      raise Puppet::Error, "sensuctl delete entity #{resource[:name]} failed\nError message: #{e.message}"
    end
    @property_hash.clear
  end
end

