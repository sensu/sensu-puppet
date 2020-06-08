require File.expand_path(File.join(File.dirname(__FILE__), '..', 'sensuctl'))
require File.expand_path(File.join(File.dirname(__FILE__), '..', 'sensu_api'))

Puppet::Type.type(:sensu_user).provide(:sensu_api, :parent => Puppet::Provider::SensuAPI) do
  desc "Provider sensu_user using sensu API"

  mk_resource_methods

  def self.instances
    users = []

    data = api_request('users', nil, {:failonfail => false})

    data.each do |d|
      user = {}
      user[:ensure] = :present
      user[:name] = d['username']
      d.each_pair do |key, value|
        next if key == 'name'
        if !!value == value
          value = value.to_s.to_sym
        end
        if type_properties.include?(key.to_sym)
          user[key.to_sym] = value
        end
      end
      users << new(user)
    end
    users
  end

  def self.prefetch(resources)
    users = instances
    resources.keys.each do |name|
      if provider = users.find { |c| c.name == name }
        resources[name].provider = provider
      end
    end
  end

  def exists?
    @property_hash[:ensure] == :present
  end

  def password_insync?(user, password)
    if password.is_a?(Array)
      password = password[0]
    end
    status = auth_test(nil, user, password)
    status
  end

  def initialize(value = {})
    super(value)
    @property_flush = {}
  end

  type_properties.each do |prop|
    define_method "#{prop}=".to_sym do |value|
      @property_flush[prop] = value
    end
  end

  def create
    data = {}
    data[:username] = resource[:name]
    data[:password] = resource[:password]
    data[:groups] = resource[:groups] if resource[:groups]
    data[:disabled] = convert_boolean_property_value(resource[:disabled]) unless resource[:disabled].nil?
    api_request('users', data, {:method => 'post'})
    if resource[:configure] == :true
      configure_cmd = ['configure', '-n', '--url', resource[:configure_url], '--username', resource[:name], '--password', resource[:password]]
      if resource[:configure_trusted_ca_file] != "absent"
        configure_cmd << '--trusted-ca-file'
        configure_cmd << resource[:configure_trusted_ca_file]
      end
      Puppet.notice('Executing sensuctl configure')
      Puppet::Provider::Sensuctl.sensuctl(configure_cmd)
    end
    @property_hash[:ensure] = :present
  end

  def flush
    if !@property_flush.empty?
      data = {}
      data[:username] = resource[:name]
      data[:password] = @property_flush[:password] || resource[:password]
      if @property_flush[:groups] || resource[:groups]
        data[:groups] = @property_flush[:groups] || resource[:groups]
      end
      if @property_flush[:disabled] || resource[:disabled]
        data[:disabled] = convert_boolean_property_value(@property_flush[:disabled] || resource[:disabled])
      end
      api_request("users/#{resource[:name]}", data, {:method => 'put'})
      if @property_flush[:password] && resource[:configure] == :true
        configure_cmd = ['configure', '-n', '--url', resource[:configure_url], '--username', resource[:name], '--password', @property_flush[:password]]
        if resource[:configure_trusted_ca_file] != "absent"
          configure_cmd << '--trusted-ca-file'
          configure_cmd << resource[:configure_trusted_ca_file]
        end
        Puppet.notice('Executing sensuctl configure')
        Puppet::Provider::Sensuctl.sensuctl(configure_cmd)
      end
    end
    @property_hash = resource.to_hash
  end

  def destroy
    api_request("users/#{resource[:name]}", nil, {:method => 'delete'})
    @property_hash.clear
  end
end

