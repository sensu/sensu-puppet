require File.expand_path(File.join(File.dirname(__FILE__), '..', 'sensuctl'))

Puppet::Type.type(:sensu_check).provide(:sensuctl, :parent => Puppet::Provider::Sensuctl) do
  desc "Provider sensu_check using sensuctl"

  mk_resource_methods

  def self.ignore_keys
    [
      'duration', 'history', 'issued', 'status', 'total_state_change', 'total_state-change',
      'executed', 'last_ok', 'occurrences', 'occurrences_watermark', 'output'
    ]
  end

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
      check[:extended_attributes] = {}
      d.each_pair do |key,value|
        next if key == 'name'
        next if key == 'proxy_requests'
        next if ignore_keys.include?(key)
        if !!value == value
          value = value.to_s.to_sym
        end
        # Handle extended_attributes property
        if key == 'subdue'
          check[:subdue_days] = value['days'] unless value.nil?
        elsif ! type_properties.include?(key.to_sym)
          check[:extended_attributes][key] = value
        else
          check[key.to_sym] = value
        end
      end
      if d['proxy_requests']
        check[:proxy_requests] = :present
        d['proxy_requests'].each_pair do |k,v|
          property = "proxy_requests_#{k}".to_sym
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
    spec = resource[:extended_attributes] || {}
    spec[:name] = resource[:name]
    type_properties.each do |property|
      value = resource[property]
      next if value.nil?
      next if value == :absent || value == [:absent]
      next if property.to_s =~ /^proxy_requests/
      next if property == :extended_attributes
      if [:true, :false].include?(value)
        value = convert_boolean_property_value(value)
      end
      if property == :subdue_days
        spec[:subdue] = { days: value }
      else
        spec[property] = value
      end
    end
    if resource[:proxy_requests_entity_attributes] ||  resource[:proxy_requests_splay] || resource[:proxy_requests_splay_coverage]
      spec[:proxy_requests] = {}
      spec[:proxy_requests][:entity_attributes] = resource[:proxy_requests_entity_attributes] if resource[:proxy_requests_entity_attributes]
      spec[:proxy_requests][:splay] = convert_boolean_property_value(resource[:proxy_requests_splay]) if resource[:proxy_requests_splay]
      spec[:proxy_requests][:splay_coverage] = resource[:proxy_requests_splay_coverage] if resource[:proxy_requests_splay_coverage]
    end
    begin
      sensuctl_create('check', spec)
    rescue Exception => e
      raise Puppet::Error, "sensuctl create #{resource[:name]} failed\nError message: #{e.message}"
    end
    @property_hash[:ensure] = :present
  end

  def flush
    if !@property_flush.empty?
      spec = @property_flush[:extended_attributes] || resource[:extended_attributes] || {}
      spec[:name] = resource[:name]
      type_properties.each do |property|
        if @property_flush[property]
          value = @property_flush[property]
        else
          value = resource[property]
        end
        next if value.nil?
        next if property.to_s =~ /^proxy_requests/
        next if property == :extended_attributes
        if [:true, :false].include?(value)
          value = convert_boolean_property_value(value)
        end
        if property == :subdue_days
          spec[:subdue] = { days: value }
        elsif value == :absent
          spec[property] = nil
        else
          spec[property] = value
        end
      end
      # Use values from existing resource then overwrite with new values if they exist
      if resource[:proxy_requests_entity_attributes] || resource[:proxy_requests_splay] || resource[:proxy_requests_splay_coverage]
        spec[:proxy_requests] = {}
        spec[:proxy_requests][:entity_attributes] = resource[:proxy_requests_entity_attributes] if resource[:proxy_requests_entity_attributes]
        spec[:proxy_requests][:splay] = convert_boolean_property_value(resource[:proxy_requests_splay]) if resource[:proxy_requests_splay]
        spec[:proxy_requests][:splay_coverage] = resource[:proxy_requests_splay_coverage] if resource[:proxy_requests_splay_coverage]
      end
      if @property_flush[:proxy_requests_entity_attributes] || @property_flush[:proxy_requests_splay] || @property_flush[:proxy_requests_splay_coverage]
        spec[:proxy_requests] = {} unless spec[:proxy_requests]
        spec[:proxy_requests][:entity_attributes] = @property_flush[:proxy_requests_entity_attributes] if @property_flush[:proxy_requests_entity_attributes]
        spec[:proxy_requests][:splay] = convert_boolean_property_value(@property_flush[:proxy_requests_splay]) if @property_flush[:proxy_requests_splay]
        spec[:proxy_requests][:splay_coverage] = @property_flush[:proxy_requests_splay_coverage] if @property_flush[:proxy_requests_splay_coverage]
      end
      begin
        sensuctl_create('check', spec)
      rescue Exception => e
        raise Puppet::Error, "sensuctl create #{resource[:name]} failed\nError message: #{e.message}"
      end
    end
    @property_hash = resource.to_hash
  end

  def destroy
    begin
      sensuctl_delete('check', resource[:name])
    rescue Exception => e
      raise Puppet::Error, "sensuctl delete check #{resource[:name]} failed\nError message: #{e.message}"
    end
    @property_hash.clear
  end
end

