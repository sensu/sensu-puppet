require 'json' if Puppet.features.json?
require File.expand_path(File.join(File.dirname(__FILE__), '..', '..', '..',
                                   'puppet_x', 'sensu', 'provider_create.rb'))
require File.expand_path(File.join(File.dirname(__FILE__), '..', '..', '..',
                                   'puppet_x', 'sensu', 'to_type.rb'))

Puppet::Type.type(:sensu_check).provide(:json) do
  confine :feature => :json
  include PuppetX::Sensu::ToType
  include PuppetX::Sensu::ProviderCreate

  SENSU_CHECK_PROPERTIES = Puppet::Type.type(:sensu_check).validproperties.reject { |p| p == :ensure }

  def conf
    begin
      @conf ||= JSON.parse(File.read(config_file))
    rescue
      @conf ||= {}
    end
  end

  def flush
    sort_properties
    File.open(config_file, 'w') do |f|
      f.puts JSON.pretty_generate(conf)
    end
  end

  def pre_create
    conf['checks'] = {}
    conf['checks'][resource[:name]] = {}
  end

  def sort_properties
    conf['checks'][resource[:name]] = Hash[conf['checks'][resource[:name]].sort]
  end

  def is_property?(prop)
    SENSU_CHECK_PROPERTIES.map(&:to_s).include? prop
  end

  def custom
    conf['checks'][resource[:name]].reject { |k,v| is_property?(k) }
  end

  def custom=(value)
    conf['checks'][resource[:name]].delete_if { |k,v| not is_property?(k) }
    conf['checks'][resource[:name]].merge!(to_type(value))
  end

  def destroy
    @conf = nil
  end

  def exists?
    conf.has_key?('checks') and conf['checks'].has_key?(resource[:name])
  end

  def config_file
    "#{resource[:base_path]}/#{resource[:name]}.json"
  end

  # Generate setters and getters for sensu_check properties.
  SENSU_CHECK_PROPERTIES.each do |property|
    # The ensure property uses #create, #exists, and #destroy we can't generate
    # meaningful setters and getters for this
    # The custom property is handled above
    next if [:ensure, :custom].include?(property)

    define_method(property) do
      get_property(property)
    end

    define_method("#{property}=") do |value|
      set_property(property, value)
    end
  end

  def get_property(property)
    value = conf['checks'][resource[:name]][property.to_s]
    value.nil? ? :absent : value
  end

  def set_property(property, value)
    if value == :absent
      conf['checks'][resource[:name]].delete(property.to_s)
    else
      conf['checks'][resource[:name]][property.to_s] = value
    end
  end

end
