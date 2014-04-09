require 'rubygems' if RUBY_VERSION < '1.9.0' && Puppet.version < '3'
require 'json' if Puppet.features.json?

begin
  require 'puppet_x/sensu/to_type'
rescue LoadError => e
  libdir = Pathname.new(__FILE__).parent.parent.parent.parent
  require File.join(libdir, 'puppet_x/sensu/to_type')
end

Puppet::Type.type(:sensu_filter).provide(:json) do
  confine :feature => :json
  include Puppet_X::Sensu::Totype

  def initialize(*args)
    super
    @conf = nil
  end

  def conf
    begin
      @conf ||= JSON.parse(File.read(config_file))
    rescue
      @conf ||= {}
    end
  end

  def config_file
    "#{resource[:base_path]}/#{resource[:name]}.json"
  end

  def flush
    File.open(config_file, 'w') do |f|
      f.puts JSON.pretty_generate(conf)
    end
  end

  def create
    conf['filter'] = {}
    conf['filter'][resource[:name]] = {}
    self.negate = resource[:negate]
  end

  def destroy
    conf = nil
  end

  def exists?
    conf.has_key?('filter') and conf['filter'].has_key?(resource[:name])
  end

  def negate
    case conf['filter'][resource[:name]]['negate']
    when true
      :true
    else
      :false
    end
  end

  def negate=(value)
    case value
    when true, 'true', 'True', :true, 1
      conf['filter'][resource[:name]]['negate'] = true
    else
      conf['filter'][resource[:name]]['negate'] = false
    end
  end

  def attributes
    conf['filter'][resource[:name]]['attributes']
  end

  def attributes=(value)
    conf['filter'][resource[:name]]['attributes'].merge!(to_type value)
  end

end
