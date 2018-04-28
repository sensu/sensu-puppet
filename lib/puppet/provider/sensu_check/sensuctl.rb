require File.expand_path(File.join(File.dirname(__FILE__), '..', 'sensuctl'))

Puppet::Type.type(:sensu_check).provide(:sensuctl, :parent => Puppet::Provider::Sensuctl) do
  desc "Provider sensu_check using sensuctl"

  mk_resource_methods

  def self.instances
    checks = []

    output = sensuctl_list('check')
    Puppet.debug("sensu checks: #{output}")
    begin
      data = JSON.parse(output)
    rescue JSON::ParserError => e
      Puppet.debug('Unable to parse output from sensuctl check list')
      data = []
    end

    data.each do |d|
      check = {}
      check[:ensure] = :present
      check[:name] = d['name']
      type_properties.each do |property|
        next unless d.key?(property.to_s)
        value = d[property.to_s]
        if !!value == value
          value = value.to_s.to_sym
        end
        check[property.to_sym] = value
      end
      if d['proxy_requests']
        d['proxy_requests'].each_pair do |k,v|
          property = "proxy_requests_#{k}".to_sym
          Puppet.debug("property=#{property}")
          if type_properties.include?(property)
            check[property] = v
          end
        end
      end
      checks << new(check)
    end
    checks
  end

  def self.prefetch(resources)
    checks = instances
    resources.keys.each do |name|
      if provider = checks.find { |c| c.name == name }
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
    flags = []
    false_properties = []
    type_properties.each do |property|
      value = resource[property]
      next if value.nil?
      next if value == :absent || value == [:absent]
      next if property.to_s =~ /^proxy_requests_/
      # Can't pass flags for false
      if value == :false
        false_properties << property.to_s
        next
      end
      flags << "--" + property.to_s.gsub('_', '-')
      if value.is_a?(Array)
        flags << value.join(',')
      elsif value == :true
        next
      elsif value == :false
        next
      else
        flags << value
      end
    end
    proxy_requests = nil
    if resource[:proxy_requests_entity_attributes] ||  resource[:proxy_requests_splay] || resource[:proxy_requests_splay_coverage]
      proxy_requests = {}
      proxy_requests[:entity_attributes] = resource[:proxy_requests_entity_attributes] if resource[:proxy_requests_entity_attributes]
      proxy_requests[:splay] = convert_boolean_property_value(resource[:proxy_requests_splay]) if resource[:proxy_requests_splay]
      proxy_requests[:splay_coverage] = resource[:proxy_requests_splay_coverage] if resource[:proxy_requests_splay_coverage]
      proxy_requests_temp = Tempfile.new('proxy_requests')
      proxy_requests_temp.write(JSON.pretty_generate(proxy_requests))
      proxy_requests_temp.close
      Puppet.debug(IO.read(proxy_requests_temp.path))
    end
    begin
      sensuctl_create('check', resource[:name], flags)
      if proxy_requests
        sensuctl_set('check', resource[:name], 'proxy-requests', flags: ['--file', proxy_requests_temp.path])
      end
      unless false_properties.empty?
        false_properties.each do |p|
          sensuctl_set('check', resource[:name], p, value: 'false')
        end
      end
    rescue Exception => e
      raise Puppet::Error, "sensuctl create check #{name} failed\nError message: #{e.message}"
    end
    @property_hash[:ensure] = :present
  end

  def flush
    if !@property_flush.empty?
      type_properties.each do |property|
        value = @property_flush[property]
        next if value.nil?
        next if property.to_s =~ /^proxy_requests_/
        if value.is_a?(Array)
          value = value.join(',')
        end
        if value == :absent
          sensuctl_remove('check', resource[:name], property.to_s)
        else
          sensuctl_set('check', resource[:name], property.to_s, value: value)
        end
      end
      if @property_flush[:proxy_requests_entity_attributes] == :absent && @property_flush[:proxy_requests_splay] == :absent && @property_flush[:proxy_requests_splay_coverage] == :absent
        sensuctl_remove('check', resource[:name], 'proxy-requests')
      elsif @property_flush[:proxy_requests_entity_attributes] || @property_flush[:proxy_requests_splay] || @property_flush[:proxy_requests_splay_coverage]
        proxy_requests = {}
        proxy_requests[:entity_attributes] = @property_flush[:proxy_requests_entity_attributes] if @property_flush[:proxy_requests_entity_attributes]
        proxy_requests[:splay] = convert_boolean_property_value(@property_flush[:proxy_requests_splay]) if @property_flush[:proxy_requests_splay]
        proxy_requests[:splay_coverage] = @property_flush[:proxy_requests_splay_coverage] if @property_flush[:proxy_requests_splay_coverage]
        proxy_requests_temp = Tempfile.new('proxy_requests')
        proxy_requests_temp.write(JSON.pretty_generate(proxy_requests))
        proxy_requests_temp.close
        Puppet.debug(IO.read(proxy_requests_temp.path))
        sensuctl_set('check', resource[:name], 'proxy-requests', flags: ['--file', proxy_requests_temp.path])
      end
    end
    @property_hash = resource.to_hash
  end

  def destroy
    begin
      sensuctl_delete('check', resource[:name])
    rescue Exception => e
      raise Puppet::Error, "sensuctl delete check #{name} failed\nError message: #{e.message}"
    end
    @property_hash.clear
  end

end

