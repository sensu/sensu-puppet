require 'json' if Puppet.features.json?
require File.expand_path(File.join(File.dirname(__FILE__), '..', '..', '..',
                                   'puppet_x', 'sensu', 'provider_create.rb'))

Puppet::Type.type(:sensu_extension).provide(:json) do
  confine :feature => :json
  include PuppetX::Sensu::ProviderCreate

  def conf
    begin
      @conf ||= JSON.parse(File.read(config_file))
    rescue
      @conf ||= {}
    end
  end

  def flush
    File.open(config_file, 'w') do |f|
      f.puts JSON.pretty_generate(conf)
    end
  end

  def pre_create
    conf[resource[:name]] = {}
  end

  def config_file
    "#{resource[:base_path]}/#{resource[:name]}.json"
  end

  def destroy
    conf.delete resource[:name]
  end

  def exists?
    conf.has_key? resource[:name]
  end

  def config
    conf[resource[:name]]
  end

  def config=(value)
    conf[resource[:name]] = value
  end
end
