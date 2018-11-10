require File.expand_path(File.join(File.dirname(__FILE__), '..', 'sensuctl'))

Puppet::Type.type(:sensu_hook).provide(:sensuctl, :parent => Puppet::Provider::Sensuctl) do
  desc "Provider sensu_hook using sensuctl"

  mk_resource_methods

  def self.instances
    hooks = []

    output = sensuctl_list('hook')
    Puppet.debug("sensu hooks: #{output}")
    begin
      data = JSON.parse(output)
    rescue JSON::ParserError => e
      Puppet.debug('Unable to parse output from sensuctl hook list')
      data = []
    end

    data.each do |d|
      hook = {}
      hook[:ensure] = :present
      hook[:name] = d['metadata']['name']
      hook[:namespace] = d['metadata']['namespace']
      d.each_pair do |key, value|
        next if key == 'metadata'
        if !!value == value
          value = value.to_s.to_sym
        end
        if type_properties.include?(key.to_sym)
          hook[key.to_sym] = value
        end
      end
      hooks << new(hook)
    end
    hooks
  end

  def self.prefetch(resources)
    hooks = instances
    resources.keys.each do |name|
      if provider = hooks.find { |c| c.name == name }
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
    spec[:metadata] = {}
    spec[:metadata][:name] = resource[:name]
    type_properties.each do |property|
      value = resource[property]
      next if value.nil?
      next if value == :absent || value == [:absent]
      if [:true, :false].include?(value)
        value = convert_boolean_property_value(value)
      end
      if property == :namespace
        spec[:metadata][:namespace] = value
      else
        spec[property] = value
      end
    end
    begin
      sensuctl_create('hook', spec)
    rescue Exception => e
      raise Puppet::Error, "sensuctl create #{resource[:name]} failed\nError message: #{e.message}"
    end
    @property_hash[:ensure] = :present
  end

  def flush
    if !@property_flush.empty?
      spec = {}
      spec[:metadata] = {}
      spec[:metadata][:name] = resource[:name]
      type_properties.each do |property|
        if @property_flush[property]
          value = @property_flush[property]
        else
          value = resource[property]
        end
        next if value.nil?
        if [:true, :false].include?(value)
          value = convert_boolean_property_value(value)
        elsif value == :absent
          value = nil
        end
        if property == :namespace
          spec[:metadata][:namespace] = value
        else
          spec[property] = value
        end
      end
      begin
        sensuctl_create('hook', spec)
      rescue Exception => e
        raise Puppet::Error, "sensuctl create #{resource[:name]} failed\nError message: #{e.message}"
      end
    end
    @property_hash = resource.to_hash
  end

  def destroy
    begin
      sensuctl_delete('hook', resource[:name])
    rescue Exception => e
      raise Puppet::Error, "sensuctl delete hook #{resource[:name]} failed\nError message: #{e.message}"
    end
    @property_hash.clear
  end
end

