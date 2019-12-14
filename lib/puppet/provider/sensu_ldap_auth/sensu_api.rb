require File.expand_path(File.join(File.dirname(__FILE__), '..', 'sensu_api'))

Puppet::Type.type(:sensu_ldap_auth).provide(:sensu_api, :parent => Puppet::Provider::SensuAPI) do
  desc "Provider sensu_ldap_auth using sensu API"

  mk_resource_methods

  def self.instances
    auths = []

    data = api_request('authproviders', nil, {:api_group => 'enterprise/authentication'})
    data.each do |d|
      next unless d['type'] == 'ldap'
      auth = {}
      auth[:ensure] = :present
      auth[:name] = d['metadata']['name']
      auth[:servers] = d['spec']['servers']
      auth[:groups_prefix] = d['spec']['groups_prefix']
      auth[:username_prefix] = d['spec']['username_prefix']
      auths << new(auth)
    end
    auths
  end

  def self.prefetch(resources)
    auths = instances
    resources.keys.each do |name|
      if provider = auths.find { |c| c.name == name }
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
    spec[:servers] = resource[:servers]
    spec[:groups_prefix] = resource[:groups_prefix] if resource[:groups_prefix]
    spec[:username_prefix] = resource[:username_prefix] if resource[:username_prefix]
    data = {}
    data[:spec] = spec
    data[:metadata] = metadata
    data[:type] = 'ldap'
    data[:api_version] = 'authentication/v2'
    opts = {
      :api_group => 'enterprise/authentication',
      :method    => 'put',
    }
    api_request("authproviders/#{resource[:name]}", data, opts)
    @property_hash[:ensure] = :present
  end

  def flush
    if !@property_flush.empty?
      spec = {}
      metadata = {}
      metadata[:name] = resource[:name]
      spec[:servers] = @property_flush[:servers] || resource[:servers]
      spec[:groups_prefix] = @property_flush[:groups_prefix] || resource[:groups_prefix]
      spec[:username_prefix] = @property_flush[:username_prefix] || resource[:username_prefix]
      data = {}
      data[:spec] = spec
      data[:metadata] = metadata
      data[:type] = 'ldap'
      data[:api_version] = 'authentication/v2'
      opts = {
        :api_group => 'enterprise/authentication',
        :method    => 'put',
      }
      api_request("authproviders/#{resource[:name]}", data, opts)
    end
    @property_hash = resource.to_hash
  end

  def destroy
    opts = {
      :api_group => 'enterprise/authentication',
      :method    => 'delete',
    }
    api_request("authproviders/#{resource[:name]}", nil, opts)
    @property_hash.clear
  end
end

