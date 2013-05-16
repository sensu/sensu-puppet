require 'rubygems' if RUBY_VERSION < '1.9.0' && Puppet.version < '3'
require 'json' if Puppet.features.json?

Puppet::Type.type(:sensu_api_config).provide(:json) do
  confine :feature => :json

  # Internal: Retrieve the current contents of /etc/sensu/config.json.
  #
  # Returns a Hash representation of the JSON structure in
  # /etc/sensu/config.json or an empty Hash if the file can not be read.
  def conf
    begin
      @conf ||= JSON.parse(File.read('/etc/sensu/conf.d/api.json'))
    rescue
      @conf ||= {}
    end
  end

  # Public: Save changes to the API section of /etc/sensu/config.json to disk.
  #
  # Returns nothing.
  def flush
    File.open('/etc/sensu/conf.d/api.json', 'w') do |f|
      f.puts JSON.pretty_generate(@conf)
    end
  end

  # Public: Create the API configuration section.
  #
  # Returns nothing.
  def create
    conf['api'] = {}
    self.port = resource[:port]
    self.host = resource[:host]
  end

  # Public: Remove the API configuration section.
  #
  # Returns nothing.
  def destroy
    conf.delete 'api'
  end

  # Public: Determine if the API configuration section is present.
  #
  # Returns a Boolean, true if present, false if absent.
  def exists?
    conf.has_key? 'api'
  end

  # Public: Retrieve the port number that the API is configured to listen on.
  #
  # Returns the String port number.
  def port
    conf['api']['port'].to_s
  end

  # Public: Set the port that the API should listen on.
  #
  # Returns nothing.
  def port=(value)
    conf['api']['port'] = value.to_i
  end

  # Public: Retrieve the hostname that the API is configured to listen on.
  #
  # Returns the String hostname.
  def host
    conf['api']['host']
  end

  # Public: Set the hostname that the API should listen on.
  #
  # Returns nothing.
  def host=(value)
    conf['api']['host'] = value
  end
end
