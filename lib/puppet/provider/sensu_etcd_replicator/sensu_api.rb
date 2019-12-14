require File.expand_path(File.join(File.dirname(__FILE__), '..', 'sensu_api'))

Puppet::Type.type(:sensu_etcd_replicator).provide(:sensu_api, :parent => Puppet::Provider::SensuAPI) do
  desc "Provider sensu_etcd_replicator using sensu API"

  mk_resource_methods

  def self.instances
    replicators = []

    opts = {
      :api_group => 'enterprise/federation',
      :api_version => 'v1',
    }
    data = api_request('etcd-replicators', nil, opts)

    data.each do |d|
      replicator = {}
      replicator[:ensure] = :present
      replicator[:name] = d['metadata']['name']
      d['spec'].each_pair do |key,value|
        if !!value == value
          value = value.to_s.to_sym
        end
        key = 'resource_name' if key == 'resource'
        if type_properties.include?(key.to_sym)
          replicator[key.to_sym] = value
        else
          next
        end
      end
      replicators << new(replicator)
    end
    replicators
  end

  def self.prefetch(resources)
    replicators = instances
    resources.keys.each do |name|
      if provider = replicators.find { |c| c.name == name }
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
      property = :resource if property == :resource_name
      spec[property] = value
    end
    data = {}
    data[:spec] = spec
    data[:metadata] = metadata
    data[:api_version] = 'federation/v1'
    data[:type] = 'EtcdReplicator'
    opts = {
      :api_group => 'enterprise/federation',
      :api_version => 'v1',
      :method => 'post',
    }
    api_request('etcd-replicators', data, opts)
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
        property = :resource if property == :resource_name
        spec[property] = value
      end
      data = {}
      data[:spec] = spec
      data[:metadata] = metadata
      data[:api_version] = 'federation/v1'
      data[:type] = 'EtcdReplicator'
      opts = {
        :api_group => 'enterprise/federation',
        :api_version => 'v1',
        :method => 'put',
      }
      api_request("etcd-replicators/#{resource[:name]}", data, opts)
    end
    @property_hash = resource.to_hash
  end

  def destroy
    opts = {
      :api_group => 'enterprise/federation',
      :api_version => 'v1',
      :method => 'delete',
    }
    api_request("etcd-replicators/#{resource[:name]}", nil, opts)
    @property_hash.clear
  end
end
