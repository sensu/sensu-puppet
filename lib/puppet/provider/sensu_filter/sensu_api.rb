require File.expand_path(File.join(File.dirname(__FILE__), '..', 'sensu_api'))

Puppet::Type.type(:sensu_filter).provide(:sensu_api, :parent => Puppet::Provider::SensuAPI) do
  desc "Provider sensu_filter using sensu API"

  mk_resource_methods

  def self.instances
    filters = []

    namespaces.each do |namespace|
      data = api_request('filters', nil, {:namespace => namespace})
      next if data.nil?
      data.each do |d|
        filter = {}
        filter[:ensure] = :present
        filter[:resource_name] = d['metadata']['name']
        filter[:namespace] = d['metadata']['namespace']
        filter[:name] = "#{filter[:resource_name]} in #{filter[:namespace]}"
        filter[:labels] = d['metadata']['labels']
        filter[:annotations] = d['metadata']['annotations']
        d.each_pair do |key, value|
          next if key == 'metadata'
          if !!value == value
            value = value.to_s.to_sym
          end
          if type_properties.include?(key.to_sym)
            filter[key.to_sym] = value
          end
        end
        filters << new(filter)
      end
    end
    filters
  end

  def self.prefetch(resources)
    filters = instances
    resources.keys.each do |name|
      if provider = filters.find { |c| c.resource_name == resources[name][:resource_name] && c.namespace == resources[name][:namespace] }
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
    metadata[:name] = resource[:resource_name]
    type_properties.each do |property|
      value = resource[property]
      next if value.nil?
      next if value == :absent || value == [:absent]
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
    api_request('filters', spec, opts)
    @property_hash[:ensure] = :present
  end

  def flush
    if !@property_flush.empty?
      spec = {}
      metadata = {}
      metadata[:name] = resource[:resource_name]
      type_properties.each do |property|
        if @property_flush[property]
          value = @property_flush[property]
        else
          value = resource[property]
        end
        next if value.nil?
        next if property.to_s =~ /^socket/
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
      api_request("filters/#{resource[:resource_name]}", spec, opts)
    end
    @property_hash = resource.to_hash
  end

  def destroy
    opts = {
      :namespace => resource[:namespace],
      :method => 'delete',
    }
    api_request("filters/#{resource[:resource_name]}", nil, opts)
    @property_hash.clear
  end
end

