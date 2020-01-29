require File.expand_path(File.join(File.dirname(__FILE__), '..', 'sensuctl'))

Puppet::Type.type(:sensu_secret).provide(:sensuctl, :parent => Puppet::Provider::Sensuctl) do
  desc "Provider sensu_secret using sensuctl"

  mk_resource_methods

  defaultfor :kernel => ['Linux','windows']

  def self.instances
    secrets = []

    data = sensuctl_list('secret')

    data.each do |d|
      secret = {}
      secret[:ensure] = :present
      secret[:resource_name] = d['metadata']['name']
      secret[:namespace] = d['metadata']['namespace']
      secret[:name] = "#{secret[:resource_name]} in #{secret[:namespace]}"
      secret[:id] = d['id']
      secret[:secrets_provider] = d['provider']
      secrets << new(secret)
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
    begin
      sensuctl_create('Secret', metadata, spec, 'secrets/v1')
    rescue Exception => e
      raise Puppet::Error, "sensuctl create #{resource[:name]} failed\nError message: #{e.message}"
    end
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
      begin
        sensuctl_create('Secret', metadata, spec, 'secrets/v1')
      rescue Exception => e
        raise Puppet::Error, "sensuctl create #{resource[:name]} failed\nError message: #{e.message}"
      end
    end
    @property_hash = resource.to_hash
  end

  def destroy
    begin
      sensuctl_delete('secret', resource[:resource_name], resource[:namespace])
    rescue Exception => e
      raise Puppet::Error, "sensuctl delete secret #{resource[:name]} failed\nError message: #{e.message}"
    end
    @property_hash.clear
  end
end

