require File.expand_path(File.join(File.dirname(__FILE__), '..', 'sensuctl'))

Puppet::Type.type(:sensu_postgres_config).provide(:sensuctl, :parent => Puppet::Provider::Sensuctl) do
  desc "Provider sensu_postgres_config using sensuctl"

  mk_resource_methods

  def min_version
    {
      strict: '6.1.0',
      batch_buffer: '6.1.0',
      batch_size: '6.1.0',
      batch_workers: '6.1.0',
    }
  end

  def self.instances
    configs = []

    data = dump('store/v1.PostgresConfig')

    data.each do |d|
      config = {}
      config[:ensure] = :present
      config[:name] = d['metadata']['name']
      d['spec'].each_pair do |key,value|
        if !!value == value
          value = value.to_s.to_sym
        end
        if type_properties.include?(key.to_sym)
          config[key.to_sym] = value
        else
          next
        end
      end
      configs << new(config)
    end
    configs
  end

  def self.prefetch(resources)
    configs = instances
    resources.keys.each do |name|
      if provider = configs.find { |c| c.name == name }
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
      if min_version.key?(property)
        v = min_version[property]
        if ! version_cmp(v)
          Puppet.warning("Sensu_postgres_config[#{resource[:name]}] Property #{property} skipped, does not meet minimum Sensu Go version of #{v}")
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
      sensuctl_create('PostgresConfig', metadata, spec, 'store/v1')
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
            Puppet.warning("Sensu_postgres_config[#{resource[:name]}] Property #{property} skipped, does not meet minimum Sensu Go version of #{v}")
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
        sensuctl_create('PostgresConfig', metadata, spec, 'store/v1')
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
    type_properties.each do |property|
      if @property_hash[property]
        value = @property_hash[property]
      else
        value = resource[property]
      end
      next if value.nil?
      if min_version.key?(property)
        v = min_version[property]
        if ! version_cmp(v)
          Puppet.warning("Sensu_postgres_config[#{resource[:name]}] Property #{property} skipped, does not meet minimum Sensu Go version of #{v}")
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
      sensuctl_delete('PostgresConfig', resource[:name], nil, metadata, spec, 'store/v1')
    rescue Exception => e
      raise Puppet::Error, "sensuctl delete check #{resource[:name]} failed\nError message: #{e.message}"
    end
    @property_hash.clear
  end
end

