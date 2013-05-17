require 'rubygems' if RUBY_VERSION < '1.9.0' && Puppet.version < '3'
require 'json' if Puppet.features.json?

Puppet::Type.type(:sensu_dashboard_config).provide(:json) do
  confine :feature => :json

  def conf
    begin
      @conf ||= JSON.parse(File.read('/etc/sensu/conf.d/dashboard.json'))
    rescue
      @conf ||= {}
    end
  end

  def flush
    File.open('/etc/sensu/conf.d/dashboard.json', 'w') do |f|
      f.puts JSON.pretty_generate(conf)
    end
  end

  def create
    conf['dashboard'] = {}
    self.port = resource[:port]
    self.host = resource[:host]
    self.user = resource[:user]
    self.password = resource[:password]
  end

  def destroy
    conf.delete 'dashboard'
  end

  def exists?
    conf.has_key? 'dashboard'
  end

  def port
    conf['dashboard']['port'].to_s
  end

  def port=(value)
    conf['dashboard']['port'] = value.to_i
  end

  def host
    conf['dashboard']['host']
  end

  def host=(value)
    conf['dashboard']['host'] = value
  end

  def user
    conf['dashboard']['user']
  end

  def user=(value)
    conf['dashboard']['user'] = value
  end

  def password
    conf['dashboard']['password']
  end

  def password=(value)
    conf['dashboard']['password'] = value
  end
end
