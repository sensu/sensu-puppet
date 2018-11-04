require File.expand_path(File.join(File.dirname(__FILE__), '..', 'sensuctl'))

Puppet::Type.type(:sensu_filter).provide(:sensuctl, :parent => Puppet::Provider::Sensuctl) do
  desc "Provider sensu_filter using sensuctl"

  mk_resource_methods

  def self.instances
    filters = []

    output = sensuctl_list('filter')
    Puppet.debug("sensu filters: #{output}")
    begin
      data = JSON.parse(output)
    rescue JSON::ParserError => e
      Puppet.debug('Unable to parse output from sensuctl filter list')
      data = []
    end

    data.each do |d|
      filter = {}
      filter[:ensure] = :present
      filter[:name] = d['name']
      d.each_pair do |key, value|
        next if key == 'name'
        if !!value == value
          value = value.to_s.to_sym
        end
        if key == 'when'
          filter[:when_days] = value['days']
        elsif type_properties.include?(key.to_sym)
          filter[key.to_sym] = value
        end
      end
      filters << new(filter)
    end
    filters
  end

  def self.prefetch(resources)
    filters = instances
    resources.keys.each do |name|
      if provider = filters.find { |c| c.name == name }
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
        value = convert_boolean_property_value(value)
      end
      if property == :when_days
        spec[:when] = { days: value }
      else
        spec[property] = value
      end
    end
    begin
      sensuctl_create('EventFilter', spec)
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
        next if property.to_s =~ /^socket/
        if [:true, :false].include?(value)
          value = convert_boolean_property_value(value)
        elsif value == :absent
          value = nil
        end
        if property == :when_days
          spec[:when] = { days: value }
        else
          spec[property] = value
        end
      end
      begin
        sensuctl_create('EventFilter', spec)
      rescue Exception => e
        raise Puppet::Error, "sensuctl create #{resource[:name]} failed\nError message: #{e.message}"
      end
    end
    @property_hash = resource.to_hash
  end

  def destroy
    begin
      sensuctl_delete('filter', resource[:name])
    rescue Exception => e
      raise Puppet::Error, "sensuctl delete filter #{resource[:name]} failed\nError message: #{e.message}"
    end
    @property_hash.clear
  end
end

