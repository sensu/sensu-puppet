require File.expand_path(File.join(File.dirname(__FILE__), '..', 'sensu_api'))

Puppet::Type.type(:sensu_secrets_vault_provider).provide(:sensu_api, :parent => Puppet::Provider::SensuAPI) do
  desc "Provider sensu_secrets_vault_provider using sensu API"

  mk_resource_methods

  def self.instances
    secrets_providers = []

    data = api_request('providers', nil, {:api_group => 'enterprise/secrets', :api_version => 'v1', :failonfail => false})
    data.each do |d|
      next unless d['type'] == 'VaultProvider'
      secrets_provider = {}
      secrets_provider[:ensure] = :present
      secrets_provider[:name] = d['metadata']['name']
      client = d['spec']['client'] || {}
      client.each_pair do |key,value|
        if !!value == value
          value = value.to_s.to_sym
        end
        if type_properties.include?(key.to_sym)
          secrets_provider[key.to_sym] = value
        else
          next
        end
      end
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

  def get_token
    if resource[:token_file]
      token = File.read(resource[:token_file]).chomp
    else
      token = @property_flush[:token] || resource[:token]
    end
    token
  rescue Errno::ENOENT => e
    raise Puppet::Error "Unable to read token_file #{resource[:token_file]}: #{e}"
  end

  def create
    spec = {}
    metadata = {}
    metadata[:name] = resource[:name]
    spec[:client] = {}
    spec[:client][:token] = get_token
    type_properties.each do |property|
      next if property == :token
      value = resource[property]
      next if value.nil?
      next if value == :absent || value == [:absent]
      if [:true, :false].include?(value)
        value = convert_boolean_property_value(value)
      end
      spec[:client][property] = value
    end
    data = {}
    data[:spec] = spec
    data[:metadata] = metadata
    data[:type] = 'VaultProvider'
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
      spec[:client] = {}
      spec[:client][:token] = get_token
      type_properties.each do |property|
        next if property == :token
        if @property_flush[property]
          value = @property_flush[property]
        else
          value = resource[property]
        end
        next if value.nil?
        if value == :absent || value == [:absent]
          value = nil
        elsif [:true, :false].include?(value)
          value = convert_boolean_property_value(value)
        end
        spec[:client][property] = value
      end
      data = {}
      data[:spec] = spec
      data[:metadata] = metadata
      data[:type] = 'VaultProvider'
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

