require File.expand_path(File.join(File.dirname(__FILE__), '..', 'sensuctl'))

Puppet::Type.type(:sensu_secrets_vault_provider).provide(:sensuctl, :parent => Puppet::Provider::Sensuctl) do
  desc "Provider sensu_secrets_vault_provider using sensuctl"

  mk_resource_methods

  defaultfor :kernel => ['Linux','windows']

  def self.instances
    secrets_providers = []

    data = dump('secrets/v1.Provider')

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
    begin
      sensuctl_create('VaultProvider', metadata, spec, 'secrets/v1')
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
      begin
        sensuctl_create('VaultProvider', metadata, spec, 'secrets/v1')
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
    spec[:client] = {}
    type_properties.each do |property|
      if @property_hash[property]
        value = @property_hash[property]
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
    begin
      sensuctl_delete('VaultProvider', resource[:name], nil, metadata, spec, 'secrets/v1')
    rescue Exception => e
      raise Puppet::Error, "sensuctl delete #{resource[:name]} failed\nError message: #{e.message}"
    end
    @property_hash.clear
  end
end
