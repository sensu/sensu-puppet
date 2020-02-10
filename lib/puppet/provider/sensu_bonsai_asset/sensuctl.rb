require File.expand_path(File.join(File.dirname(__FILE__), '..', 'sensuctl'))
require File.expand_path(File.join(File.dirname(__FILE__), '..', 'sensu_api'))

Puppet::Type.type(:sensu_bonsai_asset).provide(:sensuctl, :parent => Puppet::Provider::Sensuctl) do
  desc "Provider sensu_bonsai_asset using sensuctl"

  mk_resource_methods

  defaultfor :kernel => ['Linux','windows']

  def self.instances
    assets = []

    data = sensuctl_list('asset')
    found_assets = []

    data.each do |d|
      asset = {}
      asset[:ensure] = :present
      asset[:bonsai_namespace] = d['metadata'].dig('annotations', 'io.sensu.bonsai.namespace')
      asset[:bonsai_name] = d['metadata'].dig('annotations', 'io.sensu.bonsai.name')
      asset[:version] = d['metadata'].dig('annotations', 'io.sensu.bonsai.version')
      if asset[:bonsai_namespace].nil? || asset[:bonsai_name].nil?
        Puppet.debug("Asset #{d['metadata']['name']} from bonsai.sensu.io lacks bonsai annotations")
        next
      end
      asset[:rename] = d['metadata']['name']
      asset[:namespace] = d['metadata']['namespace']
      asset_name = "#{asset[:rename]} in #{asset[:namespace]}"
      if found_assets.include?(asset_name)
        next
      end
      found_assets << asset_name
      asset[:name] = "#{asset[:bonsai_namespace]}/#{asset[:bonsai_name]} in #{asset[:namespace]}"
      assets << new(asset)
    end
    assets
  end

  def self.prefetch(resources)
    assets = instances
    resources.keys.each do |name|
      if provider = assets.find { |c| c.rename == resources[name][:rename] && c.namespace == resources[name][:namespace] }
        resources[name].provider = provider
      end
    end
  end

  def self.latest_version(namespace, name)
    Puppet::Provider::SensuAPI.get_bonsai_latest_version(namespace, name)
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

  def asset_add(version)
    cmd = ['asset', 'add']
    name = "#{resource[:bonsai_namespace]}/#{resource[:bonsai_name]}"
    if version && version.to_s != 'latest'
      name = "#{name}:#{version}"
    end
    cmd << name
    cmd << '--rename'
    cmd << resource[:rename]
    cmd << '--namespace'
    cmd << resource[:namespace]
    begin
      sensuctl(cmd)
    rescue Exception => e
      raise Puppet::Error, "#{cmd.join(' ')} failed\nError message: #{e.message}"
    end
  end

  def create
    asset_add(resource[:version])
    @property_hash[:ensure] = :present
  end

  def flush
    if !@property_flush.empty?
      asset_add(@property_flush[:version])
    end
    @property_hash = resource.to_hash
  end

  def destroy
    begin
      sensuctl_delete('asset', resource[:rename], resource[:namespace])
    rescue Exception => e
      raise Puppet::Error, "sensuctl delete asset #{resource[:name]} failed\nError message: #{e.message}"
    end
    @property_hash.clear
  end
end

