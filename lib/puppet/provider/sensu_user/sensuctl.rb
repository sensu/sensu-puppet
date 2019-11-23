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
    cmd = ['user', 'create']
    cmd << resource[:name]
    cmd << '--password'
    cmd << resource[:password]
    if resource[:groups]
      cmd << '--groups'
      cmd << resource[:groups].join(',')
    end
    begin
      sensuctl(cmd)
    rescue Exception => e
      raise Puppet::Error, "sensuctl user create #{resource[:name]} failed\nError message: #{e.message}"
    end
    if ! resource[:disabled].nil? && resource[:disabled].to_s == 'true'
      sensuctl(['user', 'disable', resource[:name], '--skip-confirm'])
    end
    if resource[:configure] == :true
      sensuctl(['configure', '-n', '--url', resource[:configure_url], '--username', resource[:name], '--password', resource[:password]])
    end
    @property_hash[:ensure] = :present
  end

  def flush
    if !@property_flush.empty?
      if @property_flush[:password]
        if ! resource[:old_password]
          fail("old_password is manditory when changing a password")
        end
        if ! password_insync?(resource[:name], resource[:old_password])
          fail("old_password given for #{resource[:name]} is incorrect")
        end
        sensuctl(['user', 'change-password', resource[:name], '--current-password', resource[:old_password], '--new-password', @property_flush[:password]])
        if resource[:configure] == :true
          sensuctl(['configure', '-n', '--url', resource[:configure_url], '--username', resource[:name], '--password', @property_flush[:password]])
        end
      end
      if @property_flush[:groups]
        current_groups = @property_hash[:groups] || []
        # Add groups not currently set
        @property_flush[:groups].each do |group|
          if ! current_groups.include?(group)
            sensuctl(['user', 'add-group', resource[:name], group])
          end
        end
        # Remove current groups not set by Puppet
        current_groups.each do |group|
          if ! @property_flush[:groups].include?(group)
            sensuctl(['user', 'remove-group', resource[:name], group])
          end
        end
      end
      if ! @property_flush[:disabled].nil?
        if @property_flush[:disabled].to_s == 'true'
          sensuctl(['user', 'disable', resource[:name], '--skip-confirm'])
        end
        if @property_flush[:disabled].to_s == 'false'
          sensuctl(['user', 'reinstate', resource[:name]])
        end
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

