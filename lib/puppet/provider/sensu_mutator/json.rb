require 'json' if Puppet.features.json?
require File.expand_path(File.join(File.dirname(__FILE__), '..', '..', '..',
                                   'puppet_x', 'sensu', 'provider_create.rb'))


Puppet::Type.type(:sensu_mutator).provide(:json) do
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
    conf['mutators'] = {}
    conf['mutators'][resource[:name]] = {}
    self.command = resource[:command]
  end

  def config_file
    "#{resource[:base_path]}/#{resource[:name]}.json"
  end

  def destroy
    @conf = nil
  end

  def exists?
    conf.has_key?('mutators') and conf['mutators'].has_key?(resource[:name])
  end

  def command
    conf['mutators'][resource[:name]]['command']
  end

  def command=(value)
    conf['mutators'][resource[:name]]['command'] = value
  end

  def timeout
    conf['handlers'][resource[:name]]['timeout']
  end

  def timeout=(value)
    conf['handlers'][resource[:name]]['timeout'] = value
  end
end
