require File.expand_path(File.join(File.dirname(__FILE__), '..', 'sensuctl'))

Puppet::Type.type(:sensu_role_binding).provide(:sensuctl, :parent => Puppet::Provider::Sensuctl) do
  desc "Provider sensu_role_binding using sensuctl"

  mk_resource_methods

  defaultfor :kernel => ['Linux','windows']

  def self.instances
    bindings = []

    data = sensuctl_list('role-binding')

    data.each do |d|
      binding = {}
      binding[:ensure] = :present
      binding[:resource_name] = d['metadata']['name']
      binding[:namespace] = d['metadata']['namespace']
      binding[:name] = "#{binding[:resource_name]} in #{binding[:namespace]}"
      binding[:role_ref] = d['role_ref']
      binding[:subjects] = d['subjects']
      bindings << new(binding)
    end
    bindings
  end

  def self.prefetch(resources)
    bindings = instances
    resources.keys.each do |name|
      if provider = bindings.find { |c| c.resource_name == resources[name][:resource_name] && c.namespace == resources[name][:namespace] }
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
      else
        spec[property] = value
      end
    end
    begin
      sensuctl_create('RoleBinding', metadata, spec)
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
        else
          spec[property] = value
        end
      end
      begin
        sensuctl_create('RoleBinding', metadata, spec)
      rescue Exception => e
        raise Puppet::Error, "sensuctl create #{resource[:name]} failed\nError message: #{e.message}"
      end
    end
    @property_hash = resource.to_hash
  end

  def destroy
    begin
      sensuctl_delete('role-binding', resource[:resource_name], resource[:namespace])
    rescue Exception => e
      raise Puppet::Error, "sensuctl delete role_binding #{resource[:name]} failed\nError message: #{e.message}"
    end
    @property_hash.clear
  end
end

