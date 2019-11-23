require File.expand_path(File.join(File.dirname(__FILE__), '..', 'sensuctl'))

Puppet::Type.type(:sensu_mutator).provide(:sensuctl, :parent => Puppet::Provider::Sensuctl) do
  desc "Provider sensu_mutator using sensuctl"

  mk_resource_methods

  defaultfor :kernel => ['Linux','windows']

  def self.instances
    mutators = []

    data = sensuctl_list('mutator')

    data.each do |d|
      mutator = {}
      mutator[:ensure] = :present
      mutator[:resource_name] = d['metadata']['name']
      mutator[:namespace] = d['metadata']['namespace']
      mutator[:name] = "#{mutator[:resource_name]} in #{mutator[:namespace]}"
      mutator[:labels] = d['metadata']['labels']
      mutator[:annotations] = d['metadata']['annotations']
      d.each_pair do |key, value|
        next if key == 'metadata'
        if !!value == value
          value = value.to_s.to_sym
        end
        if type_properties.include?(key.to_sym)
          mutator[key.to_sym] = value
        end
      end
      mutators << new(mutator)
    end
    mutators
  end

  def self.prefetch(resources)
    mutators = instances
    resources.keys.each do |name|
      if provider = mutators.find { |c| c.resource_name == resources[name][:resource_name] && c.namespace == resources[name][:namespace] }
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
    type_properties.each do |property|
      value = resource[property]
      next if value.nil?
      next if value == :absent || value == [:absent]
      if [:true, :false].include?(value)
        value = convert_boolean_property_value(value)
      end
      if property == :namespace
        metadata[:namespace] = value
      elsif property == :labels
        metadata[:labels] = value
      elsif property == :annotations
        metadata[:annotations] = value
      else
        spec[property] = value
      end
    end
    begin
      sensuctl_create('Mutator', metadata, spec)
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
          metadata[:namespace] = value
        elsif property == :labels
          metadata[:labels] = value
        elsif property == :annotations
          metadata[:annotations] = value
        else
          spec[property] = value
        end
      end
      begin
        sensuctl_create('Mutator', metadata, spec)
      rescue Exception => e
        raise Puppet::Error, "sensuctl create #{resource[:name]} failed\nError message: #{e.message}"
      end
    end
    @property_hash = resource.to_hash
  end

  def destroy
    begin
      sensuctl_delete('mutator', resource[:resource_name], resource[:namespace])
    rescue Exception => e
      raise Puppet::Error, "sensuctl delete mutator #{resource[:name]} failed\nError message: #{e.message}"
    end
    @property_hash.clear
  end
end

