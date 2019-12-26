require File.expand_path(File.join(File.dirname(__FILE__), '..', 'sensu_api'))

Puppet::Type.type(:sensu_namespace).provide(:sensu_api, :parent => Puppet::Provider::SensuAPI) do
  desc "Provider sensu_namespace using sensu API"

  mk_resource_methods

  def self.instances
    namespaces = []

    data = api_request('namespaces')

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
    api_request('namespaces', spec, {:method => 'post'})
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
      api_request("namespaces/#{resource[:name]}", spec, {:method => 'put'})
    end
    @property_hash = resource.to_hash
  end

  def destroy
    api_request("namespaces/#{resource[:name]}", nil, {:method => 'delete'})
    @property_hash.clear
  end
end

