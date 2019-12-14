require File.expand_path(File.join(File.dirname(__FILE__), '..', 'sensuctl'))

Puppet::Type.type(:sensu_ad_auth).provide(:sensuctl, :parent => Puppet::Provider::Sensuctl) do
  desc "Provider sensu_ad_auth using sensuctl"

  mk_resource_methods

  defaultfor :kernel => ['Linux','windows']

  def self.instances
    auths = []

    data = sensuctl_list('auth', false)

    auth_types = sensuctl_auth_types()
    data.each do |d|
      auth = {}
      auth[:ensure] = :present
      auth[:name] = d['metadata']['name']
      if auth_types[auth[:name]] != 'AD'
        next
      end
      auth[:servers] = d['servers']
      auth[:groups_prefix] = d['groups_prefix']
      auth[:username_prefix] = d['username_prefix']
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
    begin
      sensuctl_create('ad', metadata, spec, 'authentication/v2')
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
      spec[:servers] = @property_flush[:servers] || resource[:servers]
      spec[:groups_prefix] = @property_flush[:groups_prefix] || resource[:groups_prefix]
      spec[:username_prefix] = @property_flush[:username_prefix] || resource[:username_prefix]
      begin
        sensuctl_create('ad', metadata, spec, 'authentication/v2')
      rescue Exception => e
        raise Puppet::Error, "sensuctl create #{resource[:name]} failed\nError message: #{e.message}"
      end
    end
    @property_hash = resource.to_hash
  end

  def destroy
    begin
      sensuctl_delete('auth', resource[:name])
    rescue Exception => e
      raise Puppet::Error, "sensuctl delete auth #{resource[:name]} failed\nError message: #{e.message}"
    end
    @property_hash.clear
  end
end

