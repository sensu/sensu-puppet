require File.expand_path(File.join(File.dirname(__FILE__), '..', 'sensuctl'))

Puppet::Type.type(:sensu_cluster_role_binding).provide(:sensuctl, :parent => Puppet::Provider::Sensuctl) do
  desc "Provider sensu_cluster_role_binding using sensuctl"

  mk_resource_methods

  defaultfor :kernel => ['Linux','windows']

  def self.instances
    bindings = []

    data = sensuctl_list('cluster-role-binding', false)

    data.each do |d|
      binding = {}
      binding[:ensure] = :present
      binding[:name] = d['metadata']['name']
      binding[:role_ref] = d['role_ref']
      binding[:subjects] = d['subjects']
      bindings << new(binding)
    end
    bindings
  end

  def self.prefetch(resources)
    bindings = instances
    resources.keys.each do |name|
      if provider = bindings.find { |c| c.name == name }
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
      if [:true, :false].include?(value)
        value = convert_boolean_property_value(value)
      end
      spec[property] = value
    end
    begin
      sensuctl_create('ClusterRoleBinding', metadata, spec)
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
        if [:true, :false].include?(value)
          value = convert_boolean_property_value(value)
        elsif value == :absent
          value = nil
        end
        spec[property] = value
      end
      begin
        sensuctl_create('ClusterRoleBinding', metadata, spec)
      rescue Exception => e
        raise Puppet::Error, "sensuctl create #{resource[:name]} failed\nError message: #{e.message}"
      end
    end
    @property_hash = resource.to_hash
  end

  def destroy
    begin
      sensuctl_delete('cluster-role-binding', resource[:name])
    rescue Exception => e
      raise Puppet::Error, "sensuctl delete cluster_role_binding #{resource[:name]} failed\nError message: #{e.message}"
    end
    @property_hash.clear
  end
end

