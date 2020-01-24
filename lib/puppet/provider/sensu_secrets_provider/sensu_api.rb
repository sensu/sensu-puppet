require File.expand_path(File.join(File.dirname(__FILE__), '..', 'sensu_api'))

Puppet::Type.type(:sensu_secrets_provider).provide(:sensu_api, :parent => Puppet::Provider::SensuAPI) do
  desc "Provider sensu_secrets_provider using sensu API"

  mk_resource_methods

  def self.instances
    secrets_providers = []

    data = api_request('providers', nil, {:api_group => 'enterprise/secrets', :api_version => 'v1', :failonfail => false})
    data.each do |d|
      secrets_provider = {}
      secrets_provider[:ensure] = :present
      secrets_provider[:name] = d['metadata']['name']
      secrets_provider[:client] = d['spec']['client']
      secrets_providers << new(secrets_provider)
    end
    secrets_providers
  end

  def self.prefetch(resources)
    secrets_providers = instances
    resources.keys.each do |name|
      if provider = secrets_providers.find { |c| c.name == name }
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
    spec[:client] = resource[:client] if resource[:client]
    data = {}
    data[:spec] = spec
    data[:metadata] = metadata
    data[:type] = resource[:type]
    data[:api_version] = 'secrets/v1'
    opts = {
      :api_group => 'enterprise/secrets',
      :api_version => 'v1',
      :method    => 'put',
    }
    api_request("providers/#{resource[:name]}", data, opts)
    @property_hash[:ensure] = :present
  end

  def flush
    if !@property_flush.empty?
      spec = {}
      metadata = {}
      metadata[:name] = resource[:name]
      client = @property_flush[:client] || resource[:client]
      spec[:client] = client if client
      data = {}
      data[:spec] = spec
      data[:metadata] = metadata
      data[:type] = resource[:type]
      data[:api_version] = 'secrets/v1'
      opts = {
        :api_group => 'enterprise/secrets',
        :api_version => 'v1',
        :method    => 'put',
      }
      api_request("providers/#{resource[:name]}", data, opts)
    end
    @property_hash = resource.to_hash
  end

  def destroy
    opts = {
      :api_group => 'enterprise/secrets',
      :api_version => 'v1',
      :method    => 'delete',
    }
    api_request("providers/#{resource[:name]}", nil, opts)
    @property_hash.clear
  end
end

