require File.expand_path(File.join(File.dirname(__FILE__), '..', 'sensuctl'))

Puppet::Type.type(:sensu_environment).provide(:sensuctl, :parent => Puppet::Provider::Sensuctl) do
  desc "Provider sensu_environment using sensuctl"

  mk_resource_methods

  def self.instances
    environments = []

    output = sensuctl_list('environment')
    Puppet.debug("sensu environments: #{output}")
    begin
      data = JSON.parse(output)
    rescue JSON::ParserError => e
      Puppet.debug('Unable to parse output from sensuctl environment list')
      data = []
    end

    data.each do |d|
      environment = {}
      environment[:ensure] = :present
      environment[:name] = d['name']
      d.each_pair do |key, value|
        next if key == 'name'
        if !!value == value
          value = value.to_s.to_sym
        end
        if type_properties.include?(key.to_sym)
          environment[key.to_sym] = value
        end
      end
      environments << new(environment)
    end
    environments
  end

  def self.prefetch(resources)
    environments = instances
    resources.keys.each do |name|
      if provider = environments.find { |c| c.name == name }
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
    spec[:name] = resource[:name]
    type_properties.each do |property|
      value = resource[property]
      next if value.nil?
      next if value == :absent || value == [:absent]
      if [:true, :false].include?(value)
        spec[property] = convert_boolean_property_value(value)
      else
        spec[property] = value
      end
    end
    begin
      sensuctl_create('environment', spec)
    rescue Exception => e
      raise Puppet::Error, "sensuctl create #{resource[:name]} failed\nError message: #{e.message}"
    end
    @property_hash[:ensure] = :present
  end

  def flush
    if !@property_flush.empty?
      spec = {}
      spec[:name] = resource[:name]
      type_properties.each do |property|
        if @property_flush[property]
          value = @property_flush[property]
        else
          value = resource[property]
        end
        next if value.nil?
        if [:true, :false].include?(value)
          spec[property] = convert_boolean_property_value(value)
        elsif value == :absent
          spec[property] = nil
        else
          spec[property] = value
        end
      end
      begin
        sensuctl_create('environment', spec)
      rescue Exception => e
        raise Puppet::Error, "sensuctl create #{resource[:name]} failed\nError message: #{e.message}"
      end
    end
    @property_hash = resource.to_hash
  end

  def destroy
    begin
      sensuctl_delete('environment', resource[:name])
    rescue Exception => e
      raise Puppet::Error, "sensuctl delete environment #{resource[:name]} failed\nError message: #{e.message}"
    end
    @property_hash.clear
  end
end

