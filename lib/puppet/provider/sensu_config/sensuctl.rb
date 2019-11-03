require File.expand_path(File.join(File.dirname(__FILE__), '..', 'sensuctl'))

Puppet::Type.type(:sensu_config).provide(:sensuctl, :parent => Puppet::Provider::Sensuctl) do
  desc "Provider sensu_config using sensuctl"

  mk_resource_methods

  def self.instances
    configs = []

    output = sensuctl(['config', 'view', '--format', 'json'])
    Puppet.debug("sensu configs: #{output}")
    begin
      data = JSON.parse(output)
    rescue JSON::ParserError => e
      Puppet.debug('Unable to parse output from sensuctl config view')
      data = []
    end

    data.each_pair do |k,v|
      config = {}
      config[:ensure] = :present
      config[:name] = k
      config[:value] = v
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
    begin
      sensuctl(['config', "set-#{resource[:name]}", resource[:value]])
    rescue Exception => e
      raise Puppet::Error, "sensuctl set-#{resource[:name]} failed\nError message: #{e.message}"
    end
    @property_hash[:ensure] = :present
  end

  def flush
    if !@property_flush.empty?
      begin
        sensuctl(['config', "set-#{resource[:name]}", @property_flush[:value]])
      rescue Exception => e
        raise Puppet::Error, "sensuctl set-#{resource[:name]} failed\nError message: #{e.message}"
      end
    end
    @property_hash = resource.to_hash
  end

  def destroy
    Puppet.warning("sensu_config does not support ensure=absent")
  end
end

