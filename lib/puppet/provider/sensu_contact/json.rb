require 'json' if Puppet.features.json?
require File.expand_path(File.join(File.dirname(__FILE__), '..', '..', '..',
                                   'puppet_x', 'sensu', 'provider_create.rb'))

Puppet::Type.type(:sensu_contact).provide(:json) do
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
    conf['contacts'] = {}
    conf['contacts'][resource[:name]] = {}
    self.config = resource[:config]
  end

  def config_file
    "#{resource[:base_path]}/#{resource[:name]}.json"
  end

  def destroy
    @conf = nil
  end

  def exists?
    conf.has_key?('contacts') and conf['contacts'].has_key?(resource[:name])
  end

  def config
    conf['contacts'][resource[:name]]
  end

  def config=(value)
    conf['contacts'][resource[:name]] = value
  end
end
