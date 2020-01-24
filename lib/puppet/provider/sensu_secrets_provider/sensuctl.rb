require File.expand_path(File.join(File.dirname(__FILE__), '..', 'sensuctl'))

Puppet::Type.type(:sensu_secrets_provider).provide(:sensuctl, :parent => Puppet::Provider::Sensuctl) do
  desc "Provider sensu_secrets_provider using sensuctl"

  mk_resource_methods

  defaultfor :kernel => ['Linux','windows']

  def self.instances
    secrets_providers = []

    data = dump('secrets/v1.Provider')

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
    spec[:client] = resource[:client]
    begin
      sensuctl_create(resource[:type], metadata, spec, 'secrets/v1')
    rescue Exception => e
      raise Puppet::Error, "sensuctl create #{resource[:name]} failed\nError message: #{e.message}"
    end
    @property_hash[:ensure] = :present
  end

  def flush
    if !@property_flush.empty?
      spec = {}
      metadata = {}
      metadata[:name] = resource[:name]
      client = resource[:client] || @property_hash[:client]
      spec[:client] = client if client
      begin
        sensuctl_create(resource[:type], metadata, spec, 'secrets/v1')
      rescue Exception => e
        raise Puppet::Error, "sensuctl create #{resource[:name]} failed\nError message: #{e.message}"
      end
    end
    @property_hash = resource.to_hash
  end

  def destroy
    spec = {}
    metadata = {}
    metadata[:name] = resource[:name]
    client = resource[:client] || @property_hash[:client]
    spec[:client] = client if client
    begin
      sensuctl_delete(resource[:type], resource[:name], nil, metadata, spec, 'secrets/v1')
    rescue Exception => e
      raise Puppet::Error, "sensuctl delete #{resource[:name]} failed\nError message: #{e.message}"
    end
    @property_hash.clear
  end
end
