require File.expand_path(File.join(File.dirname(__FILE__), '..', 'sensuctl'))
require File.expand_path(File.join(File.dirname(__FILE__), '..', 'sensu_api'))

Puppet::Type.type(:sensu_command).provide(:sensuctl, :parent => Puppet::Provider::Sensuctl) do
  desc "Provider sensu_command using sensuctl"

  mk_resource_methods

  def self.instances
    commands = []

    data = sensuctl_list('command', false)
    data.each do |d|
      command = {}
      command[:ensure] = :present
      command[:name] = d['alias']
      bonsai_namespace = d['asset'].dig('metadata', 'annotations', 'io.sensu.bonsai.namespace')
      bonsai_name = d['asset'].dig('metadata', 'annotations', 'io.sensu.bonsai.name')
      if bonsai_namespace && bonsai_name
        command[:bonsai_name] = "#{bonsai_namespace}/#{bonsai_name}"
      end
      command[:bonsai_version] = d['asset'].dig('metadata', 'annotations', 'io.sensu.bonsai.version')
      command[:url] = d['asset']['url']
      command[:sha512] = d['asset']['sha512']
      commands << new(command)
    end
    commands
  end

  def self.prefetch(resources)
    commands = instances
    resources.keys.each do |name|
      if provider = commands.find { |c| c.name == name }
        resources[name].provider = provider
      end
    end
  end

  def self.latest_bonsai_version(bonsai_name)
    return @latest_version if @latest_version
    @latest_version = nil
    return nil if bonsai_name.nil?
    versions = []
    bonsai_asset = Puppet::Provider::SensuAPI.get_bonsai_asset(bonsai_name)
    (bonsai_asset['versions'] || []).each do |bonsai_version|
      version = bonsai_version['version']
      next unless version =~ /^[0-9]/
      versions << version
    end
    versions = versions.sort_by { |v| Gem::Version.new(v) }
    @latest_version = versions.last
    @latest_version
  end

  def exists?
    @property_hash[:ensure] == :present
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

  def install
    cmd = ['command', 'install', resource[:name]]
    if resource[:bonsai_name]
      if resource[:bonsai_version] && resource[:bonsai_version].to_s != 'latest'
        cmd << "#{resource[:bonsai_name]}:#{resource[:bonsai_version]}"
      else
        cmd << resource[:bonsai_name]
      end
    else
      cmd << '--url'
      cmd << resource[:url]
      cmd << '--checksum'
      cmd << resource[:sha512]
    end
    begin
      sensuctl(cmd)
    rescue Exception => e
      raise Puppet::Error, "#{cmd.join(' ')} failed\nError message: #{e.message}"
    end
  end

  def create
    install
    @property_hash[:ensure] = :present
  end

  def flush
    if !@property_flush.empty?
      destroy
      install
    end
    @property_hash = resource.to_hash
  end

  def destroy
    begin
      sensuctl_delete('command', resource[:name])
    rescue Exception => e
      raise Puppet::Error, "sensuctl delete command #{resource[:name]} failed\nError message: #{e.message}"
    end
    @property_hash.clear
  end
end

