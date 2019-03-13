Puppet::Type.type(:sensu_plugin).provide(:sensu_install) do
  desc "Provider sensu_check using sensuctl"

  mk_resource_methods

  commands :gem => '/opt/sensu-plugins-ruby/embedded/bin/gem'
  commands :sensu_install => 'sensu-install'

  def self.instances
    plugins = []

    output = gem('list', '--local', '^sensu-(plugins|extensions)')
    Puppet.debug("gem output: #{output}")
    output.each_line do |o|
      next unless o.start_with?('sensu-')
      # This regex matches the gem list format.
      # First capture group is non-white space
      # Second capture group is anything preceeded by space(s) wrapped in parentheses
      # Expected format:
      # gem-name (version, version)
      if o =~ /^(\S+)\s+\((.+)\)/
        gem_name = $1
        versions = $2.sub('default: ', '').split(/,\s*/)
        if gem_name.start_with?('sensu-extensions')
          extension = :true
        else
          extension = :false
        end
        plugin = {
          :name      => gem_name.sub('sensu-plugins-', '').sub('sensu-extensions-', ''),
          :ensure    => :present,
          :version   => versions.map{|v| v.split[0]}[0],
          :extension => extension,
        }
        Puppet.debug("plugin: #{plugin}")
        plugins << new(plugin)
      end
    end
    plugins
  end

  def self.prefetch(resources)
    plugins = instances
    resources.keys.each do |name|
      if provider = plugins.find { |c| c.name == name }
        resources[name].provider = provider
      end
    end
  end

  def self.latest_versions
    return @latest_versions if @latest_versions
    @latest_versions = {}
    output = gem('search', '--remote', '--all', "^sensu-(plugins|extensions)-")
    output.each_line do |o|
      # This regex matches the gem list format.
      # First capture group is non-white space
      # Second capture group is anything preceeded by space(s) wrapped in parentheses
      # Expected format:
      # gem-name (version, version)
      if o =~ /^(\S+)\s+\((.+)\)/
        gem_name = $1
        versions = $2.sub('default: ', '').split(/,\s*/)
        Puppet.debug("#{gem_name} versions: #{versions}")
        name = gem_name.sub('sensu-plugins-', '').sub('sensu-extensions-', '')
        ver = versions.map { |v| v.split[0]}[0]
        @latest_versions[name] = ver
      end
    end
    @latest_versions
  end

  def exists?
    @property_hash[:ensure] == :present
  end

  def initialize(value = {})
    super(value)
    @property_flush = {}
  end

  def version=(value)
    @property_flush[:version] = value
  end

  def install(version)
    args = []
    if resource[:extension] == :true
      args << '--extension'
      prefix = 'sensu-extensions-'
    else
      args << '--plugin'
      prefix = 'sensu-plugins-'
    end
    if version == :latest
      latest_versions = self.class.latest_versions
      version = latest_versions[resource[:name]]
    end
    if version 
      name = "#{prefix}#{resource[:name]}:#{version}"
    else
      name = resource[:name]
    end
    args << name
    if resource[:clean] == :true
      args << '--clean'
    end
    if resource[:source]
      args << '--source'
      args << resource[:source]
    end
    if resource[:proxy]
      args << '--proxy'
      args << resource[:proxy]
    end
    sensu_install(args)
  end

  def create
    begin
      install(resource[:version])
    rescue Exception => e
      raise Puppet::Error, "sensu-install of #{resource[:name]} failed\nError message: #{e.message}"
    end
    @property_hash[:ensure] = :present
  end

  def flush
    if !@property_flush.empty?
      begin
        install(@property_flush[:version])
      rescue Exception => e
        raise Puppet::Error, "sensu-install of #{resource[:name]} failed\nError message: #{e.message}"
      end
    end
    @property_hash = resource.to_hash
  end

  def destroy
    args = ['uninstall']
    if resource[:extension] == :true
      name = "sensu-extensions-#{resource[:name]}"
    else
      name = "sensu-plugins-#{resource[:name]}"
    end
    args << name
    args << '--executables'
    if resource[:version]
      args << '--version'
      args << resource[:version]
    else
      args << '--all'
    end
    begin
      gem(args)
    rescue Exception => e
      raise Puppet::Error, "sensu-install delete of #{resource[:name]} failed\nError message: #{e.message}"
    end
    @property_hash.clear
  end
end

