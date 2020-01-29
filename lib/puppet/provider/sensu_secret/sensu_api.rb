require File.expand_path(File.join(File.dirname(__FILE__), '..', 'sensu_api'))

Puppet::Type.type(:sensu_secret).provide(:sensu_api, :parent => Puppet::Provider::SensuAPI) do
  desc "Provider sensu_secret using sensu API"

  mk_resource_methods

  def self.instances
    secrets = []

    namespaces.each do |namespace|
      data = api_request('secrets', nil, {:namespace => namespace, :api_group => 'enterprise/secrets', :api_version => 'v1', :failonfail => false})
      data.each do |d|
        secret = {}
        secret[:ensure] = :present
        secret[:resource_name] = d['metadata']['name']
        secret[:namespace] = d['metadata']['namespace']
        secret[:name] = "#{secret[:resource_name]} in #{secret[:namespace]}"
        secret[:id] = d['spec']['id']
        secret[:secrets_provider] = d['spec']['provider']
        secrets << new(secret)
      end
    end
    secrets
  end

  def self.prefetch(resources)
    secrets = instances
    resources.keys.each do |name|
      if provider = secrets.find { |c| c.resource_name == resources[name][:resource_name] && c.namespace == resources[name][:namespace] }
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
    metadata[:namespace] = resource[:namespace]
    spec[:id] = resource[:id]
    spec[:provider] = resource[:secrets_provider]
    data = {}
    data[:spec] = spec
    data[:metadata] = metadata
    data[:type] = 'Secret'
    data[:api_version] = 'secrets/v1'
    opts = {
      :namespace => metadata[:namespace],
      :api_group => 'enterprise/secrets',
      :api_version => 'v1',
      :method    => 'put',
    }
    api_request("secrets/#{resource[:resource_name]}", data, opts)
    @property_hash[:ensure] = :present
  end

  def flush
    if !@property_flush.empty?
      spec = {}
      metadata = {}
      metadata[:name] = resource[:resource_name]
      metadata[:namespace] = resource[:namespace]
      spec[:id] = @property_flush[:id] || resource[:id]
      spec[:provider] = @property_flush[:secrets_provider] || resource[:secrets_provider]
      data = {}
      data[:spec] = spec
      data[:metadata] = metadata
      data[:type] = 'Secret'
      data[:api_version] = 'secrets/v1'
      opts = {
        :namespace => metadata[:namespace],
        :api_group => 'enterprise/secrets',
        :api_version => 'v1',
        :method    => 'put',
      }
      api_request("secrets/#{resource[:resource_name]}", data, opts)
    end
    @property_hash = resource.to_hash
  end

  def destroy
    opts = {
      :namespace => resource[:namespace],
      :api_group => 'enterprise/secrets',
      :api_version => 'v1',
      :method    => 'delete',
    }
    api_request("secrets/#{resource[:resource_name]}", nil, opts)
    @property_hash.clear
  end
end

