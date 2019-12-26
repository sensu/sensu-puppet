require File.expand_path(File.join(File.dirname(__FILE__), '..', 'sensu_api'))

Puppet::Type.type(:sensu_cluster_role).provide(:sensu_api, :parent => Puppet::Provider::SensuAPI) do
  desc "Provider sensu_cluster_role using sensu API"

  mk_resource_methods

  def self.instances
    cluster_roles = []

    data = api_request('clusterroles')

    data.each do |d|
      cluster_role = {}
      cluster_role[:ensure] = :present
      cluster_role[:name] = d['metadata']['name']
      d.each_pair do |key, value|
        next if key == 'name'
        if !!value == value
          value = value.to_s.to_sym
        end
        if type_properties.include?(key.to_sym)
          cluster_role[key.to_sym] = value
        end
      end
      cluster_roles << new(cluster_role)
    end
    cluster_roles
  end

  def self.prefetch(resources)
    cluster_roles = instances
    resources.keys.each do |name|
      if provider = cluster_roles.find { |c| c.name == name }
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
        spec[property] = convert_boolean_property_value(value)
      else
        spec[property] = value
      end
    end
    spec[:metadata] = metadata
    api_request('clusterroles', spec, {:method => 'post'})
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
          spec[property] = convert_boolean_property_value(value)
        elsif value == :absent
          spec[property] = nil
        else
          spec[property] = value
        end
      end
      spec[:metadata] = metadata
      api_request("clusterroles/#{resource[:name]}", spec, {:method => 'put'})
    end
    @property_hash = resource.to_hash
  end

  def destroy
    api_request("clusterroles/#{resource[:name]}", nil, {:method => 'delete'})
    @property_hash.clear
  end
end

