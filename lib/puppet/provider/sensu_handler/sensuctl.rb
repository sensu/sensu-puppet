require File.expand_path(File.join(File.dirname(__FILE__), '..', 'sensuctl'))

Puppet::Type.type(:sensu_handler).provide(:sensuctl, :parent => Puppet::Provider::Sensuctl) do
  desc "Provider sensu_handler using sensuctl"

  mk_resource_methods

  def self.instances
    handlers = []

    output = sensuctl_list('handler')
    Puppet.debug("sensu handlers: #{output}")
    begin
      data = JSON.parse(output)
    rescue JSON::ParserError => e
      Puppet.debug('Unable to parse output from sensuctl handler list')
      data = []
    end

    data.each do |d|
      handler = {}
      handler[:ensure] = :present
      handler[:name] = d['name']
      type_properties.each do |property|
        next unless d.key?(property.to_s)
        value = d[property.to_s]
        if !!value == value
          value = value.to_s.to_sym
        end
        handler[property.to_sym] = value
      end
      if d['socket']
        d['socket'].each_pair do |k,v|
          property = "socket_#{k}".to_sym
          if type_properties.include?(property)
            handler[property] = v
          end
        end
      end
      handlers << new(handler)
    end
    handlers
  end

  def self.prefetch(resources)
    handlers = instances
    resources.keys.each do |name|
      if provider = handlers.find { |c| c.name == name }
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
      next if property.to_s =~ /^socket/
      if [:true, :false].include?(value)
        spec[property] = convert_boolean_property_value(value)
      else
        spec[property] = value
      end
    end
    if resource[:socket_host] ||  resource[:socket_port]
      spec[:socket] = {}
      spec[:socket][:host] = resource[:socket_host] if resource[:socket_host]
      spec[:socket][:port] = resource[:socket_port] if resource[:socket_port]
    end
    begin
      sensuctl_create('handler', spec)
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
          spec[property] = convert_boolean_property_value(value)
        elsif value == :absent
          spec[property] = nil
        else
          spec[property] = value
        end
      end
      # Use values from existing resource then overwrite with new values if they exist
      if resource[:socket_host] || resource[:socket_port]
        spec[:socket] = {}
        spec[:socket][:host] = resource[:socket_host] if resource[:socket_host]
        spec[:socket][:port] = resource[:socket_port] if resource[:socket_port]
      end
      if @property_flush[:socket_host] || @property_flush[:socket_port]
        spec[:socket] = {} unless spec[:socket]
        spec[:socket][:host] = @property_flush[:socket_host] if @property_flush[:socket_host]
        spec[:socket][:port] = @property_flush[:socket_port] if @property_flush[:socket_port]
      end
      begin
        sensuctl_create('handler', spec)
      rescue Exception => e
        raise Puppet::Error, "sensuctl create #{resource[:name]} failed\nError message: #{e.message}"
      end
    end
    @property_hash = resource.to_hash
  end

  def destroy
    begin
      sensuctl_delete('handler', resource[:name])
    rescue Exception => e
      raise Puppet::Error, "sensuctl delete handler #{name} failed\nError message: #{e.message}"
    end
    @property_hash.clear
  end
end

