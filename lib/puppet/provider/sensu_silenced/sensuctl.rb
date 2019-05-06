require File.expand_path(File.join(File.dirname(__FILE__), '..', 'sensuctl'))

Puppet::Type.type(:sensu_silenced).provide(:sensuctl, :parent => Puppet::Provider::Sensuctl) do
  desc "Provider sensu_silenced using sensuctl"

  mk_resource_methods

  def self.instances
    silencings = []

    data = sensuctl_list('silenced')

    data.each do |d|
      silenced = {}
      silenced[:ensure] = :present
      silenced[:name] = d['metadata']['name']
      silenced[:namespace] = d['metadata']['namespace']
      silenced[:labels] = d['metadata']['labels']
      silenced[:annotations] = d['metadata']['annotations']
      d.each_pair do |key,value|
        next if key == 'metadata'
        if !!value == value
          value = value.to_s.to_sym
        end
        silenced[key.to_sym] = value
      end
      silencings << new(silenced)
    end
    silencings
  end

  def self.prefetch(resources)
    silencings = instances
    resources.keys.each do |name|
      if provider = silencings.find { |s|
          s.check == (resources[name][:check] || :absent) &&
          s.subscription == (resources[name][:subscription] || :absent)
          }
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
    spec[:subscription] = resource[:subscription]
    spec[:check] = resource[:check]
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
      sensuctl_create('Silenced', metadata, spec)
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
      spec[:subscription] = resource[:subscription]
      spec[:check] = resource[:check]
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
        sensuctl_create('Silenced', metadata, spec)
      rescue Exception => e
        raise Puppet::Error, "sensuctl create #{resource[:name]} failed\nError message: #{e.message}"
      end
    end
    @property_hash = resource.to_hash
  end

  def destroy
    begin
      sensuctl_delete('silenced', @property_hash[:name])
    rescue Exception => e
      raise Puppet::Error, "sensuctl delete silenced #{@property_hash[:id]} failed\nError message: #{e.message}"
    end
    @property_hash.clear
  end
end

