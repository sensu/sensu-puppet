require File.expand_path(File.join(File.dirname(__FILE__), '..', 'sensuctl'))

Puppet::Type.type(:sensu_user).provide(:sensuctl, :parent => Puppet::Provider::Sensuctl) do
  desc "Provider sensu_user using sensuctl"

  mk_resource_methods

  defaultfor :kernel => ['Linux','windows']

  def self.instances
    users = []

    data = sensuctl_list('user', false)

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
    ret = execute(['sensuctl', 'user', 'test-creds', user, '--password', password], failonfail: false)
    exitstatus = ret.exitstatus
    exitstatus == 0
  end

  def password_hash(password)
    begin
      hash = sensuctl(['user', 'hash-password', password])
      return hash.strip
    rescue Exception => e
      Puppet.warning("Unable to generate password hash for user #{resource[:name]}: #{e.to_s}")
      return nil
    end
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
    spec = {}
    metadata = {}
    spec[:username] = resource[:name]
    spec[:groups] = resource[:groups] unless resource[:groups].nil?
    spec[:disabled] = convert_boolean_property_value(resource[:disabled]) unless resource[:disabled].nil?
    hash = password_hash(resource[:password])
    if hash
      spec[:password_hash] = hash
    else
      spec[:password] = resource[:password]
    end
    begin
      sensuctl_create('User', metadata, spec)
    rescue Exception => e
      raise Puppet::Error, "sensuctl create #{resource[:name]} failed\nError message: #{e.message}"
    end
    if resource[:configure] == :true
      configure_cmd = ['configure', '-n', '--url', resource[:configure_url], '--username', resource[:name], '--password', resource[:password]]
      if resource[:configure_trusted_ca_file] != "absent"
        configure_cmd << '--trusted-ca-file'
        configure_cmd << resource[:configure_trusted_ca_file]
      end
      Puppet.notice('Executing sensuctl configure')
      sensuctl(configure_cmd)
    end
    @property_hash[:ensure] = :present
  end

  def flush
    if !@property_flush.empty?
      spec = {}
      metadata = {}
      spec[:username] = resource[:name]
      groups = @property_flush[:groups] || resource[:groups]
      spec[:groups] = groups unless groups.nil?
      disabled = @property_flush[:disabled] || resource[:disabled]
      spec[:disabled] = convert_boolean_property_value(disabled) unless disabled.nil?
      password = @property_flush[:password] || resource[:password]
      hash = password_hash(password)
      if hash
        spec[:password_hash] = hash
      else
        spec[:password] = password
      end
      begin
        sensuctl_create('User', metadata, spec)
      rescue Exception => e
        raise Puppet::Error, "sensuctl create #{resource[:name]} failed\nError message: #{e.message}"
      end
      if @property_flush[:password] && resource[:configure] == :true
        configure_cmd = ['configure', '-n', '--url', resource[:configure_url], '--username', resource[:name], '--password', @property_flush[:password]]
        if resource[:configure_trusted_ca_file] != "absent"
          configure_cmd << '--trusted-ca-file'
          configure_cmd << resource[:configure_trusted_ca_file]
        end
        Puppet.notice('Executing sensuctl configure')
        sensuctl(configure_cmd)
      end
    end
    @property_hash = resource.to_hash
  end

  def destroy
    begin
      sensuctl_delete('user', resource[:name])
    rescue Exception => e
      raise Puppet::Error, "sensuctl delete user #{name} failed\nError message: #{e.message}"
    end
    @property_hash.clear
  end
end

