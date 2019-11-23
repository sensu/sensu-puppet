require File.expand_path(File.join(File.dirname(__FILE__), '..', 'sensu_api'))

Puppet::Type.type(:sensu_role).provide(:sensu_api, :parent => Puppet::Provider::SensuAPI) do
  desc "Provider sensu_role using sensu API"

  mk_resource_methods

  def self.instances
    roles = []

    namespaces.each do |namespace|
      data = api_request('roles', nil, {:namespace => namespace})
      next if data.nil?
      data.each do |d|
        role = {}
        role[:ensure] = :present
        role[:resource_name] = d['metadata']['name']
        role[:namespace] = d['metadata']['namespace']
        role[:name] = "#{role[:resource_name]} in #{role[:namespace]}"
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
    end
    roles
  end

  def self.prefetch(resources)
    roles = instances
    resources.keys.each do |name|
      if provider = roles.find { |c| c.resource_name == resources[name][:resource_name] && c.namespace == resources[name][:namespace] }
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
      else
        value = value
      end
      if property == :namespace
        metadata[:namespace] = value
      else
        spec[property] = value
      end
    end
    spec[:metadata] = metadata
    opts = {
      :namespace => spec[:metadata][:namespace],
      :method => 'post',
    }
    api_request('roles', spec, opts)
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
      spec[:metadata] = metadata
      opts = {
        :namespace => spec[:metadata][:namespace],
        :method => 'put',
      }
      api_request("roles/#{resource[:resource_name]}", spec, opts)
    end
    @property_hash = resource.to_hash
  end

  def destroy
    opts = {
      :namespace => resource[:namespace],
      :method => 'delete',
    }
    api_request("roles/#{resource[:resource_name]}", nil, opts)
    @property_hash.clear
  end
end

