require 'json'

Puppet::Type.type(:sensu_api_config).provide(:json) do
  def initialize(*args)
    super

    @conf = JSON.parse(File.read('/etc/sensu/config.json'))
  end

  def flush
    File.open('/etc/sensu/config.json', 'w') do |f|
      f.puts JSON.pretty_generate(@conf)
    end
  end

  def create
    @conf['api'] = {}
    self.port = resource[:port]
    self.host = resource[:host]
  end

  def destroy
    @conf.delete 'api'
  end

  def exists?
    @conf.has_key? 'api'
  end

  def port
    @conf['api']['port'].to_s
  end

  def port=(value)
    @conf['api']['port'] = value.to_i
  end

  def host
    @conf['api']['host']
  end

  def host=(value)
    @conf['api']['host'] = value
  end
end
