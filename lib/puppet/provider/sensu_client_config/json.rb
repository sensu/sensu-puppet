require 'json' if Puppet.features.json?
require File.expand_path(File.join(File.dirname(__FILE__), '..', '..', '..',
                                   'puppet_x', 'sensu', 'provider_create.rb'))
require File.expand_path(File.join(File.dirname(__FILE__), '..', '..', '..',
                                   'puppet_x', 'sensu', 'to_type.rb'))

Puppet::Type.type(:sensu_client_config).provide(:json) do
  confine :feature => :json
  include PuppetX::Sensu::ToType
  include PuppetX::Sensu::ProviderCreate

  # These class methods are alternatives to constants which may conflict with
  # other types and providers.

  # The configuration scope.  Used as a key into the @conf hash.
  def self.scope
    @scope ||= 'client'
  end

  def scope
    @scope ||= self.class.scope
  end

  def self.properties
    return @properties if @properties
    skip_properties = [ :ensure, :client_name, :custom ]
    # The set of properties to create getter and setter methods
    all_properties = Puppet::Type.type(:sensu_client_config).validproperties
    @properties = all_properties.reject { |p| skip_properties.include?(p) }
  end

  ##
  # Memoized method to load the configuration from the filesystem.  This
  # configuration state is modified by the property setter methods and written
  # out to the filesystem in the flush method.
  #
  # @return [Hash] configuration map
  def conf
    return @conf if @conf
    data = File.read(config_file)
    if data.length > 0
      @conf = JSON.parse(data)
    else
      @conf = {}
    end
  rescue Errno::ENOENT
    @conf = {}
  end

  ##
  # Write @conf hash out to the filesystem.
  def flush
    sort_properties!
    str = JSON.pretty_generate(conf)
    File.open(config_file, 'w') { |f| f.puts(str) }
  end

  def pre_create
    conf[scope] = {}
  end

  def sort_properties!
    conf[scope] = Hash[conf[scope].sort]
    @conf = Hash[conf.sort]
  end

  def is_property?(prop)
    valid_properties = [:name, :custom, *self.class.properties]
    valid_properties.map(&:to_s).include?(prop.to_s)
  end

  def client_name
    conf[scope]['name']
  end

  def client_name=(value)
    if value == :absent
      conf[scope].delete('name')
    else
      conf[scope]['name'] = value
    end
  end

  def custom
    conf[scope].reject { |k,_| is_property?(k) }
  end

  def custom=(value)
    conf[scope].delete_if { |k,_| not is_property?(k) }
    conf[scope].merge!(to_type(value))
  end

  def destroy
    @conf = nil
  end

  def exists?
    conf.has_key?(scope)
  end

  def config_file
    File.join(resource[:base_path], 'client.json').gsub(File::SEPARATOR, File::ALT_SEPARATOR || File::SEPARATOR)
  end

  # Generate setters and getters for sensu_check properties.
  properties.each do |property|
    define_method(property) do
      get_property(property)
    end

    define_method("#{property}=") do |value|
      set_property(property, value)
    end
  end

  def get_property(property)
    value = conf[scope][property.to_s]
    value.nil? ? :absent : value
  end

  def set_property(property, value)
    if value == :absent
      conf[scope].delete(property.to_s)
    else
      conf[scope][property.to_s] = value
    end
  end
end
