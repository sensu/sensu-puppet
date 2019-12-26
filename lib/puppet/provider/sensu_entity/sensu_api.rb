require File.expand_path(File.join(File.dirname(__FILE__), '..', 'sensu_api'))

Puppet::Type.type(:sensu_entity).provide(:sensu_api, :parent => Puppet::Provider::SensuAPI) do
  desc "Provider sensu_entity using sensu API"

  mk_resource_methods

  def self.instances
    entities = []

    namespaces.each do |namespace|
      data = api_request('entities', nil, {:namespace => namespace})
      next if (data.nil? || data.empty?)
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
    spec[:metadata] = metadata
    opts = {
      :namespace => spec[:metadata][:namespace],
      :method => 'post',
    }
    api_request('entities', spec, opts)
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
      spec[:metadata] = metadata
      opts = {
        :namespace => spec[:metadata][:namespace],
        :method => 'put',
      }
      api_request("entities/#{resource[:resource_name]}", spec, opts)
    end
    @property_hash = resource.to_hash
  end

  def destroy
    opts = {
      :namespace => resource[:namespace],
      :method => 'delete',
    }
    api_request("entities/#{resource[:resource_name]}", nil, opts)
    @property_hash.clear
  end
end

