require 'rubygems' if RUBY_VERSION < '1.9.0' && Puppet.version < '3'
require 'json' if Puppet.features.json?

Puppet::Type.type(:sensu_flapjack_config).provide(:json) do
  confine :feature => :json

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

  def create
    conf['flapjack'] = {}
    self.port = resource[:port]
    self.host = resource[:host]
    self.db = resource[:db]
  end

  def config_file
    "#{resource[:base_path]}/flapjack.json"
  end

  def destroy
    conf.delete 'flapjack'
  end

  def exists?
    conf.has_key? 'flapjack'
  end

  def port
    conf['flapjack']['port'].to_s
  end

  def port=(value)
    conf['flapjack']['port'] = value.to_i
  end

  def host
    conf['flapjack']['host']
  end

  def host=(value)
    conf['flapjack']['host'] = value
  end

  def db
    conf['flapjack']['db']
  end

  def db=(value)
    conf['flapjack']['db'] = value.to_i
  end
end
