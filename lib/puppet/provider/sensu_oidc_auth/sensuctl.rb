require File.expand_path(File.join(File.dirname(__FILE__), '..', 'sensuctl'))

Puppet::Type.type(:sensu_oidc_auth).provide(:sensuctl, :parent => Puppet::Provider::Sensuctl) do
  desc "Provider sensu_oidc_auth using sensuctl"

  mk_resource_methods

  defaultfor :kernel => ['Linux','windows']

  def min_version
    {
      disable_offline_access: '6.1.0',
    }
  end

  def self.instances
    auths = []

    data = sensuctl_list('auth', false)

    auth_types = sensuctl_auth_types()
    data.each do |d|
      auth = {}
      auth[:ensure] = :present
      auth[:name] = d['metadata']['name']
      if auth_types[auth[:name]] != 'OIDC'
        next
      end
      d.each_pair do |key,value|
        next if key == 'metadata'
        if !!value == value
          value = value.to_s.to_sym
        end
        if type_properties.include?(key.to_sym)
          auth[key.to_sym] = value
        else
          next
        end
      end
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
    type_properties.each do |property|
      value = resource[property]
      next if value.nil?
      next if value == :absent || value == [:absent]
      if min_version.key?(property)
        v = min_version[property]
        if ! version_cmp(v)
          Puppet.warning("Sensu_oidc_auth[#{resource[:name]}] Property #{property} skipped, does not meet minimum Sensu Go version of #{v}")
          next
        end
      end
      if [:true, :false].include?(value)
        value = convert_boolean_property_value(value)
      end
      spec[property] = value
    end
    begin
      sensuctl_create('oidc', metadata, spec, 'authentication/v2')
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
      type_properties.each do |property|
        if @property_flush[property]
          value = @property_flush[property]
        else
          value = resource[property]
        end
        next if value.nil?
        if min_version.key?(property)
          v = min_version[property]
          if ! version_cmp(v)
            Puppet.warning("Sensu_oidc_auth[#{resource[:name]}] Property #{property} skipped, does not meet minimum Sensu Go version of #{v}")
            next
          end
        end
        if [:true, :false].include?(value)
          value = convert_boolean_property_value(value)
        elsif value == :absent
          value = nil
        end
        spec[property] = value
      end
      begin
        sensuctl_create('oidc', metadata, spec, 'authentication/v2')
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

