require 'json' if Puppet.features.json?
require File.expand_path(File.join(File.dirname(__FILE__), '..', '..', '..',
                                   'puppet_x', 'sensu', 'provider_create.rb'))

Puppet::Type.type(:sensu_enterprise_dashboard_api_config).provide(:json) do
  confine :feature => :json
  include PuppetX::Sensu::ProviderCreate

  def config_file
    "#{resource[:base_path]}/dashboard.json"
  end

  # Internal: Retrieve the current contents of /etc/sensu/dashboard.json.
  #
  # Returns a Hash representation of the JSON structure in
  # /etc/sensu/dashboard.json or an empty Hash if the file can not be read.
  def conf
    begin
      @conf ||= JSON.parse(File.read(config_file))
    rescue
      @conf ||= {}
    end
  end

  # Internal: Retrieve the sensu config block from conf
  #
  # Returns an empty Array if conf['sensu'] doesn't exist yet
  def sensu
    return @sensu if @sensu
    @sensu = conf['sensu'] ? conf['sensu'] : []
  end

  # Internal: Returns the name of the resource
  def name
    resource[:name]
  end

  # Internal: Returns the API endpoint config Hash
  #
  # Returns an empty Hash if the config block doesn't exist yet
  def api
    return @api if @api
    api_hash = sensu.find { |endpoint| endpoint['name'] == name }
    @api = api_hash ? api_hash : {}
  end

  # Public: Save changes to the 'sensu' section of /etc/sensu/dashboard.json to disk.
  #
  # Returns nothing.
  def flush
    @conf['sensu'] = @sensu

    File.open(config_file, 'w') do |f|
      f.puts JSON.pretty_generate(@conf)
    end
  end

  def pre_create
    conf['sensu'] ||= []
    sensu << { 'name' => name } unless sensu.find{|e| e['name'] == name}
  end

  # Public: Remove the API configuration section.
  #
  # Returns nothing.
  def destroy
    sensu.reject! { |api| api['name'] == name }
  end

  # Public: Determine if the specified API endpoint configuration section is present.
  #
  # Returns a Boolean, true if present, false if absent.
  def exists?
    sensu.inject(false) do |memo, api|
      memo = true if api['name'] == name
      memo
    end
  end

  # Public: Retrieve the host name of the specified API endpoint
  #
  # Returns the String host
  def host
    api['host']
  end

  # Public: Set the host name of the specified API endpoint
  #
  # Returns nothing.
  def host=(value)
    api['host'] = value
  end

  # Public: Retrieve the port number that the API is configured to listen on.
  #
  # Returns the String port number.
  def port
    api['port'].to_s
  end

  # Public: Set the port that the API should listen on.
  #
  # Returns nothing.
  def port=(value)
    api['port'] = value.to_i
  end

  # Public: Retrieve the Boolean value which determines whether to use HTTPS
  #
  # Returns the Boolean ssl.
  def ssl
    api['ssl']
  end

  # Public: Set whether to use HTTPS
  #
  # Returns nothing.
  def ssl=(value)
    api['ssl'] = value
  end

  # Public: Retrieve the Boolean value which determines whether to accept 
  # an insecure SSL certificate
  #
  # Returns the Boolean insecure.
  def insecure
    api['insecure']
  end

  # Public: Set whether to accept insecure SSL certificates
  #
  # Returns nothing.
  def insecure=(value)
    api['insecure'] = value
  end

  # Public: Retrieve the URL path of API (if not '/')
  #
  # Returns the String path.
  def path
    api['path']
  end

  # Public: Set the path of the Sensu API (if not '/')
  #
  # Returns nothing.
  def path=(value)
    api['path'] = value
  end

  # Public: Retrieve the timeout for the Sensu API, in seconds
  #
  # Returns the String timeout.
  def timeout
    api['timeout'].to_s
  end

  # Public: Set the timeout for the Sensu API, in seconds
  #
  # Returns nothing.
  def timeout=(value)
    api['timeout'] = value.to_i
  end

  # Public: Retrieve the username for API endpoint auth
  #
  # Returns the String user.
  def user
    api['user']
  end

  # Public: Set the user for API endpoint auth
  #
  # Returns nothing.
  def user=(value)
    api['user'] = value
  end

  # Public: Retrieve the password for API endpoint auth
  #
  # Returns the String pass.
  def pass
    api['pass']
  end

  # Public: Set the password for API endpoint auth
  #
  # Returns nothing.
  def pass=(value)
    api['pass'] = value
  end
end
