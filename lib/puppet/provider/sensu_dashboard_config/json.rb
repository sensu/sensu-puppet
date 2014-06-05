require 'rubygems' if RUBY_VERSION < '1.9.0' && Puppet.version < '3'
require 'json' if Puppet.features.json?

Puppet::Type.type(:sensu_dashboard_config).provide(:json) do
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
    conf['dashboard'] = {}
    self.port = resource[:port]
    self.host = resource[:host]
    self.bind = resource[:bind]
    self.user = resource[:user]
    self.password = resource[:password]
  end

  def config_file
    "#{resource[:base_path]}/dashboard.json"
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

  def bind
    conf['dashboard']['bind']
  end

  def bind=(value)
    conf['dashboard']['bind'] = value
  end

  def user
    conf['dashboard']['user'].to_s
  end

  def user=(value)
    conf['dashboard']['user'] = value
    conf['dashboard'].delete('user') if ''==value
  end

  def password
    conf['dashboard']['password'].to_s
  end

  def password=(value)
    conf['dashboard']['password'] = value
    conf['dashboard'].delete('password') if ''==value

  end
end
