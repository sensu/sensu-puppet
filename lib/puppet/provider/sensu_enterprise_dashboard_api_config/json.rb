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
    @conf ||= JSON.parse(File.read(config_file))
  rescue
    @conf ||= {}
  end

  # Internal: Retrieve the sensu config block from conf
  #
  # Returns an empty Array if conf['sensu'] doesn't exist yet
  def sensu
    return @sensu if @sensu
    @sensu = conf['sensu'] ? conf['sensu'] : []
  end

  # Internal: Returns the name of the resource
  def host
    resource[:host]
  end

  # Internal: Returns the API endpoint config Hash
  #
  # Returns an empty Hash if the config block doesn't exist yet
  def api
    return @api if @api
    api_hash = sensu.find { |endpoint| endpoint['host'] == host }
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
    sensu << { 'host' => host } unless sensu.find{|e| e['host'] == host}
  end

  # Public: Remove the API configuration section.
  #
  # Returns nothing.
  def destroy
    sensu.reject! { |api| api['host'] == host }
  end

  # Public: Determine if the specified API endpoint configuration section is present.
  #
  # Returns a Boolean, true if present, false if absent.
  def exists?
    sensu.inject(false) do |memo, api|
      memo = true if api['host'] == host
      memo
    end
  end

  # Public: Retrieve the name of the specified API endpoint
  #
  # Returns the String name
  def datacenter
    api['name']
  end

  # Public: Set the name of the specified API endpoint
  #
  # Returns nothing.
  def datacenter=(value)
    api['name'] = value
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

  # Public: Load a configuration file.
  #
  # @param [Hash] opts
  # @option opts [String] :config_file The dashboard configuration file to
  #   load.  May be specified in the environment as SENSU_DASHBOARD_JSON to
  #   affect the behavior of `puppet resource`.  Defaults to
  #   `"/etc/sensu/dashboard.json"`
  #
  # @return [Hash] the JSON object loaded from the file, e.g.:
  # {
  #   "sensu": [
  #     {
  #       "host": "sensu.example.com",
  #       "name": "example-dc",
  #       "port": 4567,
  #       "ssl": false,
  #       "insecure": false,
  #       "timeout": 5
  #     },
  #     {
  #       "host": "sensu2.example.com",
  #       "name": "example-dc",
  #       "port": 4567,
  #       "ssl": false,
  #       "insecure": false,
  #       "timeout": 5
  #     }
  #   ],
  #   "dashboard": {
  #     "host": "0.0.0.0",
  #     "port": 3000,
  #     "interval": 5,
  #     "refresh": 5
  #   }
  # }
  def self.load_config(opts = {})
    if opts[:config_file]
      fp = opts[:config_file]
    elsif not ENV['SENSU_DASHBOARD_JSON'].to_s.empty?
      fp = ENV['SENSU_DASHBOARD_JSON']
    else
      fp = '/etc/sensu/dashboard.json'
    end

    begin
      Puppet.debug "Loading: #{fp}"
      return JSON.parse(File.read(fp))
    rescue StandardError => e
      Puppet.warning "Could not load #{fp} #{e.message}"
      Puppet.warning "Using an empty config hash instead."
      return {}
    end
  end

  # Given a config, map it to provider hashes.  Intended to take the output of
  # config_file and convert it to an array of hashes suitable for initializing
  # provider instances.
  #
  # @return Array[Hash]
  def self.config_to_provider_hashes(config)
    return [] unless config['sensu']
    config['sensu'].map do |hsh|
      hsh.inject({}) do |m, (k,v)|
        case k
        when 'host'
          m[:name] = v
        when 'name'
          m[:datacenter] = v
        else
          m[k.to_sym] = v
        end
        m
      end.merge(ensure: 'present', provider: 'json')
    end
  end

  # Public: enumerate all resources, managed and unmanaged
  #
  # @return Array[Provider Instances]
  def self.instances
    config_to_provider_hashes(load_config).map do |provider_hash|
      new(provider_hash)
    end
  end
end
