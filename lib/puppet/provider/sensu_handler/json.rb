require 'json' if Puppet.features.json?
require File.expand_path(File.join(File.dirname(__FILE__), '..', '..', '..',
                                   'puppet_x', 'sensu', 'provider_create.rb'))


Puppet::Type.type(:sensu_handler).provide(:json) do
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
    conf['handlers'] = {}
    conf['handlers'][resource[:name]] = {}
    self.command = resource[:command]
    self.type = resource[:type]
  end

  def config_file
    "#{resource[:base_path]}/#{resource[:name]}.json"
  end

  def destroy
    @conf = nil
  end

  def exists?
    conf.has_key?('handlers') and conf['handlers'].has_key?(resource[:name])
  end

  def command
    conf['handlers'][resource[:name]]['command']
  end

  def command=(value)
    conf['handlers'][resource[:name]]['command'] = value
  end

  def config
    conf[resource[:name]]
  end

  def config=(value)
    conf[resource[:name]] = value
  end

  def exchange
    conf['handlers'][resource[:name]]['exchange']
  end

  def exchange=(value)
    conf['handlers'][resource[:name]]['exchange'] = value
  end

  def pipe
    conf['handlers'][resource[:name]]['pipe']
  end

  def pipe=(value)
    conf['handlers'][resource[:name]]['pipe'] = value
  end

  def socket
    conf['handlers'][resource[:name]]['socket']
  end

  def socket=(value)
    conf['handlers'][resource[:name]]['socket'] = value
    if conf['handlers'][resource[:name]]['socket'].has_key?('port')
      conf['handlers'][resource[:name]]['socket']['port'] = conf['handlers'][resource[:name]]['socket']['port'].to_i
    end
  end

  def handlers
    conf['handlers'][resource[:name]]['handlers']
  end

  def handlers=(value)
    conf['handlers'][resource[:name]]['handlers'] = value
  end

  def mutator
    conf['handlers'][resource[:name]]['mutator']
  end

  def mutator=(value)
    conf['handlers'][resource[:name]]['mutator'] = value
  end

  def filters
    conf['handlers'][resource[:name]]['filters'] || []
  end

  def filters=(value)
    if value.is_a?(Array)
      conf['handlers'][resource[:name]]['filters'] = value
    else
      conf['handlers'][resource[:name]]['filters'] = [ value ]
    end
  end

  def severities
    conf['handlers'][resource[:name]]['severities']
  end

  def severities=(value)
    conf['handlers'][resource[:name]]['severities'] = value
  end

  def type
    conf['handlers'][resource[:name]]['type']
  end

  def type=(value)
    conf['handlers'][resource[:name]]['type'] = value
  end

  def timeout
    conf['handlers'][resource[:name]]['timeout']
  end

  def timeout=(value)
    conf['handlers'][resource[:name]]['timeout'] = value
  end

  def handle_flapping
    conf['handlers'][resource[:name]]['handle_flapping']
  end

  def handle_flapping=(value)
    conf['handlers'][resource[:name]]['handle_flapping'] = value
  end

  def handle_silenced
    conf['handlers'][resource[:name]]['handle_silenced']
  end

  def handle_silenced=(value)
    conf['handlers'][resource[:name]]['handle_silenced'] = value
  end

end
