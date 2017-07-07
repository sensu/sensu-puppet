require 'json' if Puppet.features.json?
require File.expand_path(File.join(File.dirname(__FILE__), '..', '..', '..',
                                   'puppet_x', 'sensu', 'provider_create.rb'))
require File.expand_path(File.join(File.dirname(__FILE__), '..', '..', '..',
                                   'puppet_x', 'sensu', 'to_type.rb'))


Puppet::Type.type(:sensu_filter).provide(:json) do
  confine :feature => :json
  include PuppetX::Sensu::ToType
  include PuppetX::Sensu::ProviderCreate

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

  def pre_create
    conf['filters'] = {}
    conf['filters'][resource[:name]] = {}
  end

  def destroy
    @conf = nil
  end

  def exists?
    conf.has_key?('filters') and conf['filters'].has_key?(resource[:name])
  end

  def negate
    conf['filters'][resource[:name]]['negate']
  end

  def negate=(value)
    conf['filters'][resource[:name]]['negate'] = value
  end

  def attributes
    conf['filters'][resource[:name]]['attributes']
  end

  def attributes=(value)
    conf['filters'][resource[:name]]['attributes'] ||= {}
    conf['filters'][resource[:name]]['attributes'].merge!(to_type(value))
  end

  def when
    conf['filters'][resource[:name]]['when']
  end

  def when=(value)
    conf['filters'][resource[:name]]['when'] ||= {}
    conf['filters'][resource[:name]]['when'].merge!(to_type(value))
  end
end
