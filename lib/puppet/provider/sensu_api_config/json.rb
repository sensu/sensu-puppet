require 'json' if Puppet.features.json?
require File.expand_path(File.join(File.dirname(__FILE__), '..', '..', '..',
                                   'puppet_x', 'sensu', 'provider_create.rb'))

Puppet::Type.type(:sensu_api_config).provide(:json) do
  confine :feature => :json
  include PuppetX::Sensu::ProviderCreate

  # Internal: Determine the corract path to the config file
  #
  # Returns a String
  def config_file
    File.join(resource[:base_path], 'api.json').gsub(File::SEPARATOR, File::ALT_SEPARATOR || File::SEPARATOR)
  end

  # Internal: Retrieve the current contents of /etc/sensu/config.json.
  #
  # Returns a Hash representation of the JSON structure in
  # /etc/sensu/config.json or an empty Hash if the file can not be read.
  def conf
    @conf ||= JSON.parse(File.read(config_file))
  rescue
    @conf ||= {}
  end

  # Public: Save changes to the API section of /etc/sensu/config.json to disk.
  #
  # Returns nothing.
  def flush
    File.open(config_file, 'w') do |f|
      @conf['api'].delete('ssl') unless @resource.ssl?
      f.puts JSON.pretty_generate(@conf)
    end
  end

  def pre_create
    conf['api'] = {}
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
    conf.key? 'api'
  end

  # Public:  Retrieve the bind IP that the API is bound on the server
  #
  # Returns the String bind IP

  def bind
    conf['api']['bind']
  end

  # Public:  Set the IP that bind will use.
  #
  # Returns nothing.

  def bind=(value)
    conf['api']['bind'] = value
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

  # Public: Retrieve the api username
  #
  # Returns the String hostname.
  def user
    conf['api']['user']
  end

  # Public: Set the api user
  #
  # Returns nothing.
  def user=(value)
    conf['api']['user'] = value
  end

  # Public: Retrieve the password for the api
  #
  # Returns the String password.
  def password
    conf['api']['password']
  end

  # Public: Set the api password
  #
  # Returns nothing.
  def password=(value)
    conf['api']['password'] = value
  end

  # Public: Manage the SSL hash in an idempotent fashion
  #
  # Returns nothing.
  def ensure_ssl
    if @resource.ssl?
      conf['api']['ssl'] = {} unless conf['api']['ssl'].is_a?(Hash)
    elsif conf['api']['ssl'].is_a?(Hash)
      conf['api'].delete('ssl')
    end
  end

  # Public: Retrieve the port for API SSL listener
  #
  # Returns the String port.
  def ssl_port
    return conf['api']['ssl']['port'].to_s if conf['api']['ssl']
    :absent
  end

  # Public: Set the port for the API SSL listener
  #
  # Returns nothing.
  def ssl_port=(value)
    ensure_ssl
    conf['api']['ssl']['port'] = value if @resource.ssl?
  end

  # Public: Retrieve the keystore file path for the API SSL listener
  #
  # Returns the String keystore_file.
  def ssl_keystore_file
    return conf['api']['ssl']['keystore_file'] if conf['api']['ssl']
    :absent
  end

  # Public: Set the keystore file path for the API SSL listener
  #
  # Returns nothing.
  def ssl_keystore_file=(value)
    ensure_ssl
    conf['api']['ssl']['keystore_file'] = value if @resource.ssl?
  end

  # Public: Retrieve the keystore password for the API SSL listener
  #
  # Returns the String keystore_password.
  def ssl_keystore_password
    return conf['api']['ssl']['keystore_password'] if conf['api']['ssl']
    :absent
  end

  # Public: Set the keystore password for the API SSL listener
  #
  # Returns nothing.
  def ssl_keystore_password=(value)
    ensure_ssl
    conf['api']['ssl']['keystore_password'] = value if @resource.ssl?
  end
end
